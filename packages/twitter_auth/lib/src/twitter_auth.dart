import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:meta/meta.dart' show required, visibleForTesting;
import 'package:oauth1/oauth1.dart';
import 'package:twitter_auth/src/utils/exception.dart';
import 'utils/constants.dart';
import 'dart:developer' as developer;

/// The entry point to use the methods in the Twitter Auth plugin
class TwitterAuth extends FlutterAuth {
  /// The client id of the Twitter App
  final String clientId;

  /// The client id of the Twitter App
  final String clientSecret;

  /// The client id of the Twitter App
  final String callbackUrl;

  /// Whether the cache should be cleared after the login flow has completed
  /// If true, the Webview cache will be cleared
  /// The default is false.
  final bool clearCache;

  /// The user agent to be used for the Webview
  final String userAgent;

  ClientCredentials _clientCredentials;

  @visibleForTesting
  // ignore: public_member_api_docs
  Authorization authorization;

  static final dynamic _client = oauth1.Platform(
      kApiEndpointRequestToken,
      kApiEndpointAuthorize,
      kApiEndpointAccessToken,
      oauth1.SignatureMethods.hmacSha1);

  /// Returns an instance of [TwitterAuth].
  TwitterAuth(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.callbackUrl,
      this.clearCache = false,
      this.userAgent}) {
    assert(clientId != null && clientId.isNotEmpty,
        'Consumer key may not be null or empty.');
    assert(clientSecret != null && clientSecret.isNotEmpty,
        'Consumer secret may not be null or empty.');
    _clientCredentials = ClientCredentials(clientId, clientSecret);
  }

  @visibleForTesting
  @override
  // ignore: public_member_api_docs
  Future<FlutterAuthResult> loginComplete(Uri authorizedResultUrl) async {
    final queryParameters = authorizedResultUrl.queryParameters;

    final oauthToken = queryParameters[kOauthTokenConstant];
    final oauthVerifier = queryParameters[kOauthVerifierConstant];
    final denied = queryParameters[kOauthDeniedConstant];

    if (denied != null) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.cancelled,
          message: FlutterAuthExceptionMessage.cancelled);
    }

    if (oauthToken == null || oauthToken.isEmpty) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login, message: 'oauth token is null');
    }

    if (oauthVerifier == null || oauthVerifier.isEmpty) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: 'oauth verifier is null');
    }

    try {
      Credentials tokenCredentials =
          await getTokenCredentials(oauthToken, oauthVerifier);

      return FlutterAuthResult(
        token: tokenCredentials.token,
        secret: tokenCredentials.tokenSecret,
      );
    } catch (error) {
      developer.log('requestTokenCredentials: error',
          name: 'TwitterAuth', error: error);
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.credentials,
          details: error.toString());
    }
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Future<Credentials> getTokenCredentials(
      String oauthToken, String oauthVerifier) async {
    final response = await authorization
        .requestTokenCredentials(Credentials(oauthToken, ''), oauthVerifier)
        .catchError((error) {
      throw (error);
    });

    return response.credentials;
  }

  /// Starts a login flow of a twitter account.
  ///
  /// If successful, a token and secret will be returned.
  ///
  /// If an error occurs, the status will be set to [FlutterAuthStatus.error] along with an errorMessage.
  @override
  Future<FlutterAuthResult> login(BuildContext context) async {
    try {
      Credentials _tempCredentials = await getTemporaryToken();
      String url = authorization
          .getResourceOwnerAuthorizationURI(_tempCredentials.token);

      return openLoginPage(context, url);
    } catch (error) {
      throw parseLoginException(error);
    }
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Future<Credentials> getTemporaryToken() async {
    authorization = Authorization(_clientCredentials, _client);

    var response = await authorization.requestTemporaryCredentials(callbackUrl);
    return response.credentials;
  }
}
