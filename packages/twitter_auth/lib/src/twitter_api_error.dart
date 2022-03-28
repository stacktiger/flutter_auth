// https://developer.twitter.com/ja/docs/basics/response-codes

class TwitterAPIError {
  String? code;
  String? message;

  TwitterAPIError({this.code, this.message});

  /// Returns the current instance as a [Map].
  Map<String, dynamic> get asMap {
    return <String, dynamic>{
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return '$TwitterAPIError(${asMap.toString()})';
  }
}
