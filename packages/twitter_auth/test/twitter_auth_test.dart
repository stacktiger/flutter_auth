import 'package:flutter/material.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oauth1/oauth1.dart';
import 'package:twitter_auth/twitter_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:oauth1/oauth1.dart' as oauth1;

const kCallbackUrl = 'twittersdk://';
const kClientId = 'test-consumer-key';
const kClientSecret = 'test-consumer-secret';
const kToken = 'test-token';

const kAuthorizedResultUrl = 'test-authorized-result-url';

BuildContext kMockBuildContext = MockBuildContext();
late MockOAuth1 kOauth1;

void main() {
  late TwitterAuth twitterAuth;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    twitterAuth = TestTwitterAuth();
    // mockedTwitterAuth = TwitterAuth();
    kOauth1 = MockOAuth1();
  });

  test('constructor', () {
    expect(twitterAuth, isA<TwitterAuth>());
  });

  test('consumerKey', () {
    expect(twitterAuth.clientId, isA<String>());
    expect(twitterAuth.clientId, kClientId);
  });

  test('consumerSecret', () {
    expect(twitterAuth.clientSecret, isA<String>());
    expect(twitterAuth.clientSecret, kClientSecret);
  });

  test('callbackUrl', () {
    expect(twitterAuth.callbackUrl, isA<String>());
    expect(twitterAuth.callbackUrl, kCallbackUrl);
  });

  group('clearCache', () {
    test('sets to correct value', () {
      expect(twitterAuth.clearCache, true);
    });

    test('defaults to false', () {
      final twitterAuth = TwitterAuth(
          clientId: kClientId,
          clientSecret: kClientSecret,
          callbackUrl: kCallbackUrl);
      expect(twitterAuth.clearCache, false);
    });
  });

  test('login()', () async {
    when(kOauth1.requestTemporaryCredentials('oob')).thenAnswer((_) {
      return Future<AuthorizationResponse>.value(
        AuthorizationResponse(Credentials('x', 'x'), {}),
      );
    });

    final result = await twitterAuth.login(kMockBuildContext);

    expect(verify(kOauth1.requestTemporaryCredentials(any)).callCount, 1);

    expect(result, isA<FlutterAuthResult>());
    expect(result.token, kToken);
  });

  group('loginComplete()', () {
    late String mockOauthToken;
    late String mockOauthVerifier;
    late String mockOauthSecret;
    late Uri mockAuthorizedResultUrl;

    setUp(() {
      mockOauthToken = 'test-oauth-token';
      mockOauthVerifier = 'test-oauth-verifier';
      mockOauthSecret = 'test-oauth-secret';
      mockAuthorizedResultUrl = Uri.parse(
          'http://www.twitter.com/oauth?oauth_token=$mockOauthToken&oauth_verifier=$mockOauthVerifier');
    });

    test('return a [FlutterAuthResult] with [FlutterAuthStatus] success',
        () async {
      when(kOauth1.requestTokenCredentials(
              Credentials(any.toString(), any.toString()), any.toString()))
          .thenAnswer((_) => Future.value(AuthorizationResponse(
              Credentials(mockOauthToken, mockOauthSecret), {})));

      final result = await twitterAuth.loginComplete(mockAuthorizedResultUrl);

      final capturedCredentials = verify(kOauth1.requestTokenCredentials(
              Credentials(captureAny.toString(), captureAny.toString()),
              mockOauthVerifier))
          .captured[0] as Credentials;

      expect(capturedCredentials.token, mockOauthToken);
      expect(capturedCredentials.tokenSecret, '');

      expect(result, isA<FlutterAuthResult>());
      expect(result.token, mockOauthToken);
      expect(result.secret, mockOauthSecret);
    });
    test(
        'returns a [FlutterAuthResult] with [FlutterAuthStatus] error if [requestTokenCredentials] errors',
        () async {
      when(kOauth1.requestTokenCredentials(
              Credentials(any.toString(), any.toString()), any.toString()))
          .thenAnswer((_) => new Future.error('mock error'));

      try {
        await twitterAuth.loginComplete(mockAuthorizedResultUrl);
      } on FlutterAuthException catch (e) {
        final capturedCredentials = verify(kOauth1.requestTokenCredentials(
                Credentials(captureAny.toString(), captureAny.toString()),
                mockOauthVerifier))
            .captured[0] as Credentials;

        expect(capturedCredentials.token, mockOauthToken);
        expect(capturedCredentials.tokenSecret, '');

        expect(e.code, FlutterAuthExceptionCode.login);
        expect(e.message, FlutterAuthExceptionMessage.credentials);
      } catch (_) {
        fail('did not throw a [FlutterAuthException]');
      }
    });

    test(
        'return a [FlutterAuthResult] with FlutterAuthStatus.error if [oauthToken] or [oauthVerifier] is null ',
        () async {
      mockAuthorizedResultUrl = Uri.parse('http://www.twitter.com/oauth');

      try {
        await twitterAuth.loginComplete(mockAuthorizedResultUrl);
      } on FlutterAuthException catch (e) {
        expect(e.code, FlutterAuthExceptionCode.login);
        expect(e.message, 'oauth token is null');

        verifyNever(kOauth1.requestTokenCredentials(
            Credentials(any.toString(), any.toString()), any.toString()));
      } catch (_) {}
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}

class MockOAuth1 extends Mock implements oauth1.Authorization {
  Platform _platform = Platform(
      'https://api.twitter.com/oauth/request_token',
      'https://api.twitter.com/oauth/authorize',
      'https://api.twitter.com/oauth/access_token',
      SignatureMethods.hmacSha1);
  MockOAuth1() {
    Authorization(
      ClientCredentials(kClientId, kClientSecret),
      _platform
    );
  }
}

class TestTwitterAuth extends TwitterAuth {
  TestTwitterAuth()
      : super(
            callbackUrl: kCallbackUrl,
            clientId: kClientId,
            clientSecret: kClientSecret,
            clearCache: true);

  @override
  get authorization {
    return kOauth1;
  }

  @override
  openLoginPage(BuildContext context, String url) {
    return Future.value(FlutterAuthResult(token: kToken));
  }
}
