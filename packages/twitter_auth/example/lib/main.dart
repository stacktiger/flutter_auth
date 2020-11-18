import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:twitter_auth/twitter_auth.dart';
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

  Future<void> twitterSignIn(BuildContext context) async {
    final auth = TwitterAuth(
      clientId: 'xxxx',
      clientSecret: 'xxxx',
      callbackUrl: 'twittersdk://',
    );

    try {
      FlutterAuthResult resp = await auth.login(context);
      print('Successfully signed in with result $resp');
      showToast('Successfully signed in', Colors.green);
    } on FlutterAuthException catch (e) {
      switch (e.code) {
        case FlutterAuthExceptionCode.cancelled:
          print('Sign-in process was cancelled by user: ${e.toString()}');
          showToast('Sign-in process was cancelled by user', Colors.red);
          break;
        case FlutterAuthExceptionCode.network:
          print('A network exception was thrown: ${e.toString()}');
          showToast('A network exception was thrown', Colors.red);
          break;
        case FlutterAuthExceptionCode.login:
          print(
              'A exception occurred during an sign-in attempt: ${e.toString()}');
          showToast(
              'A exception occurred during an sign-in attempt', Colors.red);
          break;
        case FlutterAuthExceptionCode.denied:
          print('Sign-in process was denied: ${e.toString()}');
          showToast('Sign-in process was denied', Colors.red);
          break;
      }
    } catch (e) {
      print('A exception occurred during an sign-in attempt $e');
      showToast('A exception occurred during an sign-in attempt', Colors.red);
    }
  }

  Widget _buildNormalButton(BuildContext context) {
    return SignInButton(
      Buttons.Twitter,
      text: "Sign up with Twitter",
      onPressed: () => twitterSignIn(context),
    );
  }

  // For example purposes only, in you app replace with your own condition
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
              'Twitter Auth Example',
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
                            SizedBox(width: 50, height: 50),
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
