import 'package:flutter_auth_core/src/utils/flutter_auth_exception_code.dart';
import 'package:flutter_auth_core/src/utils/flutter_auth_exception_message.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'utils/flutter_auth_webview.dart';
import 'package:meta/meta.dart' show required, visibleForOverriding;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';

// ignore: public_member_api_docs
class FlutterAuth {
  final String clientId;
  final String clientSecret;
  final String callbackUrl;
  final bool clearCache;
  final String userAgent;
  final bool modal;

  /// Returns an instance of [FlutterAuth].
  FlutterAuth(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.callbackUrl,
      this.clearCache = false,
      this.userAgent,
      this.modal = false}) {
    assert(clientId != null && clientId.isNotEmpty,
        'ClientId may not be null or empty.');
    assert(clientSecret != null && clientSecret.isNotEmpty,
        'ClientSecret may not be null or empty.');
    assert(callbackUrl != null && callbackUrl.isNotEmpty,
        'CallbackUrl may not be null or empty.');
  }

  @visibleForOverriding
  // ignore: public_member_api_docs
  Future<FlutterAuthResult> loginComplete(Uri authorizedResultUrl) {
    throw UnimplementedError('loginComplete() has not been implemented');
  }

  // ignore: public_member_api_docs
  Future<FlutterAuthResult> openLoginPage(BuildContext context, String url) {
    return openLoginPageWithWebview(context, url);
  }

  // ignore: public_member_api_docs
  Future<FlutterAuthResult> login(BuildContext context) async {
    throw UnimplementedError('login() has not been implemented');
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Future<FlutterAuthResult> openLoginPageWithWebview(
      BuildContext context, String url) async {
    assert(context != null && url != null && url.isNotEmpty);
    var authorizedResult;

    try {
      authorizedResult = await navigateToWebview(context, url);
    } catch (e) {
      throw FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.unknown,
          details: e);
    }

    if (authorizedResult.runtimeType == String) {
      Uri urlResponse = Uri.parse(authorizedResult);
      return loginComplete(urlResponse);
    } else {
      throw convertWebviewErrorToException(authorizedResult);
    }
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  Future<dynamic> navigateToWebview(BuildContext context, String url) async {
    return Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: modal,
        builder: (context) => FlutterAuthWebview(
              url: url,
              redirectUrl: callbackUrl,
              userAgent: userAgent,
              clearCache: clearCache,
              modal: modal,
            )));
  }

  @visibleForTesting
  // ignore: public_member_api_docs
  FlutterAuthException convertWebviewErrorToException(dynamic result) {
    if (result == null) {
      return FlutterAuthException(
          code: FlutterAuthExceptionCode.cancelled,
          message: FlutterAuthExceptionMessage.cancelled);
    } else if (result is WebViewHttpError) {
      if (result.code == '-2') {
        return FlutterAuthException(
            code: FlutterAuthExceptionCode.network,
            message: FlutterAuthExceptionMessage.network);
      }
      return FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.unknownHttp,
          details: {'code:': result.code, 'url': result.url});
    } else if (result is Exception) {
      return FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.unknown,
          details: result);
    } else {
      return FlutterAuthException(
          code: FlutterAuthExceptionCode.login,
          message: FlutterAuthExceptionMessage.unknown,
          details: result);
    }
  }
}
