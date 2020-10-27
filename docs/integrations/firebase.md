# Integrate With Firebase 


First, configure your app to work with [Firebase Auth](https://firebase.flutter.dev/docs/auth/overview).

And, then use `signInWithCredential` with an `AuthCredential` instance created with the `FlutterAuthResult` obtained from the login flow.

```dart
import 'package:twitter_auth/twitter_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithTwitter() async {
  final FlutterAuth twitterAuth = TwitterAuth(
    consumerKey: '<your consumer key>',
    consumerSecret:' <your consumer secret>'
  );

  final FlutterAuthResult result = twitterAuth.login(context);

  // Start the integration by creating a credential from the access token
  final AuthCredential twitterAuthCredential =
    TwitterAuthProvider.credential(accessToken: result.token, secret: result.secret);

  await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
}
```