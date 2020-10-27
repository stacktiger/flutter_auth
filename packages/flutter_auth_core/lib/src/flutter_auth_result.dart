import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A generic class that provides the result once the login flow has completed.
class FlutterAuthResult {
  /// Returns an instance of [FlutterAuthResult].
  @protected
  FlutterAuthResult({this.token, this.secret}) : assert(token != null);

  /// The token obtained after the user has successfully logged in.
  final String token;

  /// The secret obtained after the user has successfully logged in.
  final String secret;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> get asMap {
    return <String, dynamic>{
      'token': token,
      'secret': secret,
    };
  }

  @override
  String toString() {
    return '$FlutterAuthResult(${asMap.toString()})';
  }
}
