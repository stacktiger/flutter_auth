# Overview 

<iframe src="https://player.vimeo.com/video/470797007"  height="500" frameborder="0" allow="autoplay;"></iframe>
<iframe src="https://player.vimeo.com/video/472607251"  height="500" frameborder="0" allow="autoplay;"></iframe>

## Getting Started

First, you will need to register a [OAuth App](hhttps://github.com/settings/developers/).

![GitHub Developer Account](../assets/img/github-auth-account-1.png ':size=400')

Configure your app by setting a callbackUrl, this can be any url.
![GitHub Developer Account](../assets/img/github-auth-account-2.png ':size=400')

Once registered, you'll be given a OAuth token and OAuth secret.
![GitHub Developer Account](../assets/img/github-auth-account-3.png ':size=400')

# Installation

1. Add [github_auth]() to your app's `pubspec.yaml`:
```yaml
dependencies:
  github_auth: ^5.7.8
```

2. Install it:
```bash
flutter pub get
```

3. Import the package in your Dart code: 
```dart
import 'package:github_auth/github_auth.dart';
```

# Usage

1. Create a `GithubAuth` instance with credentials from your GitHub App:
```dart
    final auth = GithubAuth(
      clientId: 'your-client-id',
      clientSecret: 'your-client-secret',
      callbackUrl: 'your-callback-url',
      scope: 'your scope' // optional, defaults to user,gist,user:email
    );
```

2. Start the login process by calling `auth.login`: 
```dart
   // BuildContext is a required arg to open the webview:
   final resp = await auth.login(context);

    // If successful, an instance of `FlutterAuthResult` is returned with a token and  secret.
    print('Successfully logged in $resp');
```

# Error Handling

Apart from the common error handling which is detailed on the [Overview](/?id=error-handling) section, if a GitHub API error message is thrown, details of the error message will be parsed as a `GithubAPIError` instance, corresponding to GitHub's [error codes](https://docs.github.com/en/free-pro-team@latest/developers/apps/authorizing-oauth-apps#error-codes-for-the-device-flow).

```dart
    try {
        final resp = await auth.login(context);
    } on FlutterAuthException catch(e) {
        // ...
        case FlutterAuthExceptionCode.login:
            if (e.details is TwitterAPIError) {
                // View the raw api error 
                var apiError = e.details;

            print('A GitHub API Error occurred with code ${apiError.code}, message $  {apiError.message} and uri ${apiError.uri}');
            } else {
                print({${e.details});
            }
        break;
    }
```
