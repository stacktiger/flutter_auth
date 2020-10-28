import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:github_auth/github_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import 'utils/constants.dart';

/// The entry point to use the methods in the Github Auth plugin
class GithubAuth extends FlutterAuth {
  /// The client id of the Github App
  final String clientId;

  /// The client id of the Twitter App
  final String clientSecret;

  /// The client id of the Twitter App
  final String callbackUrl;

  /// The client id of the Twitter App
  final String scope;

  /// Whether the login flow should allow the option to create a new account tas
  /// well as login to an existing one
  /// The default is true.
  final bool allowSignUp;

  /// Whether the cache should be cleared after the login flow has completed
  /// If true, the Webview cache will be cleared
  /// The default is false.
  final bool clearCache;

  /// The user agent to be used for the Webview
  final String userAgent;

  @visibleForTesting
  // ignore: public_member_api_docs
  final client = http.Client();

  GithubAuth(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.callbackUrl,
      this.scope = "user,gist,user:email",
      this.allowSignUp = true,
      this.clearCache = false,
      this.userAgent});

  @visibleForTesting
  @override
  // ignore: public_member_api_docs
  Future<FlutterAuthResult> loginComplete(Uri authorizedResultUrl) async {
    FlutterAuthResult result;
    // exchange for access token
    String code = authorizedResultUrl.queryParameters[kCodeConstant];

    if (code == null || code.isEmpty) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: GithubAuthExceptionMessage.emptyCode);
    }

    try {
      String accessToken = await getAccessToken(code);
      result = FlutterAuthResult(token: accessToken);
    } catch (e) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.credentials,
          details: e);
    }

    return result;
  }

  @visibleForTesting
  Future<String> getAccessToken(String code) async {
    var response = await client.post("$kApiEndpointAccessToken", headers: {
      kAcceptConstant: kAcceptJsonConstant,
    }, body: {
      kClientIdConstant: clientId,
      kClientSecretConstant: clientSecret,
      kCodeConstant: code
    });

    if (response.statusCode == 200) {
      var body = json.decode(utf8.decode(response.bodyBytes));
      var error = body[kErrorConstant];
      if (error != null) {
        throw GithubAPIError.parse(body);
      }

      return body[kAccessTokenConstant];
    } else {
      developer.log('getAccessToken: unable to parse http error: ',
          name: 'GithubAuth', error: response.body);
      throw Exception(
          "Unable to obtain access token. Received: ${response.statusCode}");
    }
  }

  Future<FlutterAuthResult> login(BuildContext context) async {
    String url = _generateAuthorizedUrl();

    return openLoginPage(context, url);
  }

  String _generateAuthorizedUrl() {
    return "$kApiEndpointAuthorize?" +
        "client_id=$clientId" +
        "&redirect_uri=$callbackUrl" +
        "&scope=$scope" +
        "&allow_signup=$allowSignUp";
  }
}
