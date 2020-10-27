import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

const kCallbackUrl = 'test-callback-url';
const kClientId = 'test-consumer-key';
const kClientSecret = 'test-consumer-secret';
const kToken = 'test-token';
const kClearCache = true;
const kUserAgent = 'test-user-agent';
const kAuthorizedResultUrl = 'test-authorized-result-url';

BuildContext kMockBuildContext = MockBuildContext();

void main() {
  TestFlutterAuthLogin testFlutterAuthLogin;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    testFlutterAuthLogin = TestFlutterAuthLogin();
  });

  group('constructor', () {
    test('args are set correctly', () {
      expect(testFlutterAuthLogin, isA<FlutterAuthLogin>());

      expect(testFlutterAuthLogin.callbackUrl, kCallbackUrl);
      expect(testFlutterAuthLogin.clientId, kClientId);
      expect(testFlutterAuthLogin.clientSecret, kClientSecret);
      expect(testFlutterAuthLogin.clearCache, kClearCache);
      expect(testFlutterAuthLogin.userAgent, kUserAgent);
    });

    test('defaults are correct', () {
      final flutterAuthLoginWithDefaults = FlutterAuthLogin(
          callbackUrl: kCallbackUrl,
          clientId: kClientId,
          clientSecret: kClientSecret);
      expect(flutterAuthLoginWithDefaults.clearCache, false);
      expect(flutterAuthLoginWithDefaults.userAgent, isNull);
    });

    test('throws AssertionError if clientId is null', () {
      try {
        FlutterAuthLogin(
            callbackUrl: kCallbackUrl,
            clientId: null,
            clientSecret: kClientSecret);
      } on AssertionError catch (e) {
        expect(e.message, 'ClientId may not be null or empty.');
      }
    });

    test('throws AssertionError if clientSecret is null', () {
      try {
        FlutterAuthLogin(
            callbackUrl: kCallbackUrl, clientId: kClientId, clientSecret: null);
      } on AssertionError catch (e) {
        expect(e.message, 'ClientSecret may not be null or empty.');
      }
    });

    test('throws AssertionError if callbackUrl is null', () {
      try {
        FlutterAuthLogin(
          callbackUrl: null,
          clientId: kClientId,
          clientSecret: kClientSecret,
        );
      } on AssertionError catch (e) {
        expect(e.message, 'CallbackUrl may not be null or empty.');
      }
    });
  });

  test('loginComplete() throws an UnimplementedError ', () {
    try {
      testFlutterAuthLogin.loginComplete(Uri.parse('mock'));
    } on UnimplementedError catch (e) {
      expect(e.message, 'loginComplete() has not been implemented');
    }
  });

  group('openLoginPageWithWebview() ', () {
    test('returns a [FlutterAuthResult]', () async {
      final result = await testFlutterAuthLogin.openLoginPageWithWebview(
          kMockBuildContext, 'http://url.com');

      expect(result, isA<FlutterAuthResult>());
      expect(result.token, 'test');
    });

    test('throws a [FlutterAuthException] if [authorizedResult] is null', () {
      // TODO
    });

    test(
        'throws a [FlutterAuthException] if [authorizedResult] result is a Exception',
        () {
      // TODO
    });

    test('throws AssertionError if context is null', () {
      expect(
          () => testFlutterAuthLogin.openLoginPageWithWebview(
              null, 'http://url.com'),
          throwsAssertionError);
    });

    test('throws AssertionError if url is null', () {
      expect(
          () => testFlutterAuthLogin.openLoginPageWithWebview(
              kMockBuildContext, null),
          throwsAssertionError);
    });

    test('throws AssertionError if url is empty', () {
      expect(
          () => testFlutterAuthLogin.openLoginPageWithWebview(
              kMockBuildContext, ''),
          throwsAssertionError);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}

class TestFlutterAuthLogin extends FlutterAuthLogin {
  TestFlutterAuthLogin()
      : super(
            callbackUrl: kCallbackUrl,
            clientId: kClientId,
            clientSecret: kClientSecret,
            clearCache: kClearCache,
            userAgent: kUserAgent);

  @override
  navigateToWebview(BuildContext context, String url) {
    return Future.value('mock-url');
  }

  // @override
  loginComplete(Uri url) {
    return Future.value(FlutterAuthResult(token: 'test', secret: null));
  }
}
