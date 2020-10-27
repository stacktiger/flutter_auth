import 'dart:io';
import 'dart:convert';
import 'package:flutter_auth_core/flutter_auth_core.dart';
import 'package:twitter_auth/twitter_auth.dart';
import 'package:xml_parser/xml_parser.dart';

dynamic parseLoginException(error) {
  if (error is! Exception ||
      error is! SocketException ||
      error is! StateError) {
    return error;
  }

  FlutterAuthException exception;
  if (error is SocketException) {
    if (error.message != null && error.message.contains("Failed host lookup")) {
      exception = FlutterAuthException(
          code: FlutterAuthExceptionCode.network,
          message: 'No network',
          details: error.toString());
    }
  } else if (error is StateError) {
    final apiError = parseTwitterApiError(error);

    exception = FlutterAuthException(
      code: FlutterAuthExceptionCode.login,
      message: FlutterAuthExceptionMessage.credentials,
      details: apiError,
    );
  } else {
    exception = FlutterAuthException(
        code: FlutterAuthExceptionCode.login,
        message: FlutterAuthExceptionMessage.unknown,
        details: error.toString());
  }

  return exception;
}

TwitterAPIError parseTwitterApiError(StateError error) {
  List<XmlElement> errors = XmlElement.parseString(
    error.message,
    returnElementsNamed: ['error'],
    start: 0,
    stop: 1,
  );

  if (errors == null) {
    var json = jsonDecode(error.message)['errors'][0];

    return TwitterAPIError(code: '${json['code']}', message: json['message']);
  }

  return TwitterAPIError(
      code: errors.first.getAttribute('code'), message: errors.first.text);
}
