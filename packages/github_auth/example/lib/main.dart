import 'package:flutter/material.dart';

import 'dart:async';
import 'package:github_auth/github_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(App());
}

class App extends StatelessWidget {
  void showToast(String message, MaterialColor color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> githubSignIn(BuildContext context) async {
    final auth = GithubAuth(
      clientId: 'xxxx',
      clientSecret: 'xxxx',
      callbackUrl: 'https://stacktiger-flutter.firebaseapp.com/__/auth/handler',
      clearCache: false,
    );

    try {
      FlutterAuthResult resp = await auth.login(context);
      print('Successfully retrieved result ${resp.toString()}');
      showToast('Successfully signed in', Colors.green);
    } on FlutterAuthException catch (e) {
      switch (e.code) {
        case FlutterAuthExceptionCode.login:
          print('A exception occurred during a login attempt: ${e.toString()}');
          if (e.details != null && e.details is GithubAPIError) {
            print('A GithubAPIError ${e.details.code} ${e.details.uri}');
          }
          showToast('A exception occurred during a login attempt', Colors.red);
          break;
        case FlutterAuthExceptionCode.cancelled:
          print('Login process was cancelled by user: ${e.toString()}');
          showToast('Login process was cancelled by user', Colors.red);
          break;
        case FlutterAuthExceptionCode.network:
          print('A network exception was thrown: ${e.toString()}');
          showToast('A network exception was thrown', Colors.red);
          break;
        case FlutterAuthExceptionCode.denied:
          print('Sign-in process was denied: ${e.toString()}');
          showToast('Sign-in process was denied', Colors.red);
          break;
      }
    } catch (e) {
      print('Exception $e');
    }
  }

  Widget _buildNormalButton(BuildContext context) {
    return SignInButton(
      Buttons.GitHub,
      onPressed: () => githubSignIn(context),
    );
  }

  // For example purposes only, in you app replace with your own condition
  // e.g. Future<void> _initialization = await Firebase.initializeApp();
  final Future<String> _initialization = Future<String>.delayed(
    Duration(seconds: 0),
    () => 'Firebase App Initialized',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'GitHub Auth Example',
              key: Key('title'),
            ),
          ),
          body: FutureBuilder(
              future: _initialization,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    return SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                          Column(children: <Widget>[
                            SizedBox(height: 50),
                            _buildNormalButton(context)
                          ])
                        ]));
                  default:
                    return Center(child: Text('Loading'));
                }
              })),
    );
  }
}
