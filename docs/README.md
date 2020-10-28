<p align="center">
    <img width="430px" src="assets/img/flutter_auth.png"><br/>
  <h1 align="center">
    Overview
   </h1>
</p>


flutter_auth is a family of flutter plugins that provides an interface to sign-in with social auth providers:

- Twitter
- GitHub

## Features

- Unified API making integration easy.
- Simple Error handling

## Example App

Each plugin has their own example project that demonstrates their basic usage. Or, there's a standalone example app on [GitHub](https://github.com/stacktiger/flutter_auth_example) that you can check out.

<img src="https://cdn.stacktiger.co/images/flutter_auth/flutter_auth_example_app.jpg" alt="drawing" width="200"/>

## Installation

See specific plugin for details:
 - [Twitter Auth Installation](/twitter/overview?id=installation)
 - [GitHub Auth Installation](/github/overview?id=installation)

## Usage

#### 1. Create a `FlutterAuth` instance

```dart
// Swap `FlutterAuth` for your chosen social provider
// For example, TwitterAuth() or GithubAuth()
var auth = FlutterAuth(
    clientId: 'your-client-id',
    clientSecret: 'your-client-secret',
    callbackUrl: 'your-callback-url',
);
```

#### 2. Start the auth flow by calling `login()`.

```dart
// BuildContext is a required arg to open the webview:
final result = await auth.login(context);

// If successful, an instance of `FlutterAuthResult` is returned with a token and a secret.
print('Successfully logged in $resp');
```

## Error Handling

If there was an error, a `FlutterAuthException` will be thrown. A `FlutterAuthException` has a `code` and `message` where `code` can be one of the following values:

- `FlutterAuthExceptionCode.cancelled` - Indicates the request was cancelled by the user.
- `FlutterAuthExceptionCode.network` - Indicates a network error occurred.
- `FlutterAuthExceptionCode.login` - Indicates there was an error during the login process.

```dart
try {
    final resp = await auth.login(context);
} on FlutterAuthException catch(e) {
    switch(e.code) {
        case FlutterAuthExceptionCode.cancelled:
            print('Sign-in process was cancelled by user: ${e.toString()}');
            break;
        case FlutterAuthExceptionCode.network:
            print('A network exception was thrown: ${e.toString()}');
            break;
        case FlutterAuthExceptionCode.login:
            print(
                'An exception occurred during a sign-in attempt: ${e.toString()}');
            break;
     };
}
```

Exceptions with a `login` code, may contain more details about the raw exception. If an error from the social provider is thrown, they will be stored in the `details` property. See each plugin's documentation to learn more.
