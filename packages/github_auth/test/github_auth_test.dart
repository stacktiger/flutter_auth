import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_auth/github_auth.dart';
import 'package:github_auth/src/utils/constants.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

BuildContext kMockBuildContext = MockBuildContext();
MockHttpClient kClient;

const kCallbackUrl = 'githubsdk://';
const kClientId = 'test-consumer-key';
const kClientSecret = 'test-consumer-secret';
const kScope = 'user';
const kAllowSignUp = false;
const kUserAgent = 'test-user-agent';
const kToken = 'test-token';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GithubAuth githubAuth;

  setUp(() {
    githubAuth = TestGithubAuth();
    kClient = MockHttpClient();
  });

  test('constructor', () {
    expect(githubAuth, isA<GithubAuth>());
  });

  test('consumerKey', () {
    expect(githubAuth.clientId, isA<String>());
    expect(githubAuth.clientId, kClientId);
  });

  test('consumerSecret', () {
    expect(githubAuth.clientSecret, isA<String>());
    expect(githubAuth.clientSecret, kClientSecret);
  });

  test('callbackUrl', () {
    expect(githubAuth.callbackUrl, isA<String>());
    expect(githubAuth.callbackUrl, kCallbackUrl);
  });

  test('scope', () {
    expect(githubAuth.scope, isA<String>());
    expect(githubAuth.scope, kScope);
  });

  test('allowSignUp', () {
    expect(githubAuth.allowSignUp, isA<bool>());
    expect(githubAuth.allowSignUp, kAllowSignUp);
  });

  test('clearCache', () {
    expect(githubAuth.clearCache, true);
  });

  test('userAgent', () {
    expect(githubAuth.userAgent, kUserAgent);
  });

  test('default values', () {
    GithubAuth githubAuthWithDefaults = GithubAuth(
        clientId: kClientId,
        clientSecret: kClientSecret,
        callbackUrl: kCallbackUrl);
    expect(githubAuthWithDefaults.scope, "user,gist,user:email");
    expect(githubAuthWithDefaults.allowSignUp, true);
    expect(githubAuthWithDefaults.clearCache, false);
    expect(githubAuthWithDefaults.userAgent, isNull);
  });

  test('login()', () async {
    final result = await githubAuth.login(kMockBuildContext);

    expect(result, isA<FlutterAuthResult>());
    expect(result.token, kToken);
    expect(result.secret, isNull);
  });

  group('loginComplete()', () {
    String mockCode;
    String mockAccessToken;
    Uri mockAuthorizedResultUrl;

    setUp(() {
      mockCode = 'test-code';
      mockAccessToken = 'test-access-token';
      mockAuthorizedResultUrl =
          Uri.parse('http://www.github.com/oauth?code=$mockCode');
    });

    test('return a [FlutterAuthResult] with [FlutterAuthStatus] success',
        () async {
      when(kClient.post(kApiEndpointAccessToken,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async =>
              http.Response('{"access_token": "$mockAccessToken"}', 200));

      final result = await githubAuth.loginComplete(mockAuthorizedResultUrl);

      expect(result, isA<FlutterAuthResult>());
      expect(result.token, mockAccessToken);
      expect(result.secret, isNull);
    });

    test(
        'returns a [FlutterAuthResult] with [FlutterAuthStatus] error if code is null',
        () async {
      mockAuthorizedResultUrl = Uri.parse('http://www.github.com/oauth?code=');

      try {
        await githubAuth.loginComplete(mockAuthorizedResultUrl);
      } on FlutterAuthException catch (e) {
        expect(e.code, FlutterAuthExceptionCode.login);
        expect(e.message, GithubAuthExceptionMessage.emptyCode);
      } catch (_) {
        fail('did not throw a [FlutterAuthException]');
      }
    });

    test(
        'returns a [FlutterAuthResult] with [FlutterAuthStatus] error if statusCode != 200',
        () async {
      when(kClient.post(kApiEndpointAccessToken,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('mock error', 400));

      try {
        await githubAuth.loginComplete(mockAuthorizedResultUrl);
      } on FlutterAuthException catch (e) {
        expect(e.code, FlutterAuthExceptionCode.login);
        expect(e.message, FlutterAuthExceptionMessage.credentials);
      } catch (_) {
        fail('did not throw a [FlutterAuthException]');
      }
    });

    test(
        'return a [FlutterAuthResult] with FlutterAuthStatus.error if [accessToken] is null ',
        () async {
      when(kClient.post(kApiEndpointAccessToken,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('mock error', 400));

      try {
        await githubAuth.loginComplete(mockAuthorizedResultUrl);
      } on FlutterAuthException catch (e) {
        expect(e.code, FlutterAuthExceptionCode.login);
        expect(e.message, FlutterAuthExceptionMessage.credentials);
      } catch (_) {
        fail('did not throw a [FlutterAuthException]');
      }
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}

class MockHttpClient extends Mock implements http.Client {}

class TestGithubAuth extends GithubAuth {
  TestGithubAuth()
      : super(
            callbackUrl: kCallbackUrl,
            clientId: kClientId,
            clientSecret: kClientSecret,
            allowSignUp: kAllowSignUp,
            scope: kScope,
            userAgent: kUserAgent,
            clearCache: true);

  @override
  get client {
    return kClient;
  }

  @override
  openLoginPage(BuildContext context, String url) {
    // TODO: spy on method args to test they are correct
    return Future.value(FlutterAuthResult(token: kToken));
  }
}
