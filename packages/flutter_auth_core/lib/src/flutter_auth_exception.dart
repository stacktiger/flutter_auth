import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_core/flutter_auth_core.dart';

/// A generic class that provides details of the exception.
class FlutterAuthException {
  /// Returns an instance of [FlutterAuthResult].
  @protected
  FlutterAuthException({this.code, this.message, this.details});

  /// The error code
  final FlutterAuthExceptionCode code;

  /// Description of the error thrown
  final String message;

  /// Additional details of the error thrown
  final dynamic details;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> get asMap {
    return <String, dynamic>{
      'code': code,
      'message': message,
      'details': details
    };
  }

  @override
  String toString() {
    return '$FlutterAuthException(${asMap.toString()})';
  }
}
