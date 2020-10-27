## Overview 

<iframe src="https://player.vimeo.com/video/470793272" height="500" frameborder="0" allow="autoplay; " ></iframe>
<iframe src="https://player.vimeo.com/video/472606533"  height="500" frameborder="0" allow="autoplay;"></iframe>

## Getting Started

First, you will need a [Twitter developer account](https://developer.twitter.com/). Once you've registered, [create an app](https://developer.twitter.com/en/portal/apps/new).

![Twitter Developer Account](../assets/img/twitter-auth-account-1.png ':size=400')

Then, configure your app by setting a callbackUrl.
![Twitter Developer Account](../assets/img/twitter-auth-account-2.png ':size=400')

If you need to get an email address from your user's twitter account, enable email:
![Twitter Developer Account](../assets/img/twitter-auth-account-2a.png ':size=400')

# Installation

1. Add [twitter_auth]() to your app's `pubspec.yaml`:
```yaml
dependencies:
  twitter_auth: ^5.7.8
```

2. Install it:
```bash
flutter pub get
```

3. Import the package in your Dart code: 
```dart
import 'package:twitter_auth/twitter_auth.dart';
```

# Usage

1. Create a `TwitterAuth` instance with credentials from your Twitter App:
```dart
final auth = TwitterAuth(
    clientId: 'your-client-id',
    clientSecret: 'your-client-secret',
    callbackUrl: 'your-callback-url',
);
```

2. Start the login process by calling `auth.login`: 
```dart
// BuildContext is a required arg to open the webview:
final resp = await auth.login(context);

// If successful, an instance of `FlutterAuthResult` is returned with a token and a secret.
print('Successfully logged in $resp');
```

# Error Handling

Apart from the common error handling which is detailed in the [Overview](/?id=error-handling) section, if a Twitter API error message is thrown, details of the error message will be parsed as a `TwitterAPIError` instance, corresponding to [response codes](https://developer.twitter.com/ja/docs/basics/response-codes).

```dart
try {
    final resp = await auth.login(context);
} on FlutterAuthException catch(e) {
    // ...
    case FlutterAuthExceptionCode.login:
        if (e.details is TwitterAPIError) {
            // View the raw api error 
            var apiError = e.details;

            print('A Twitter API Error occurred with code ${apiError.code} and message ${apiError.message}');
        } else {
            print({${e.details});
        }
        break;
}
```
