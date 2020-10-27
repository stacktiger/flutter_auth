// https://docs.github.com/en/free-pro-team@latest/developers/apps/authorizing-oauth-apps#error-codes-for-the-device-flow

class GithubAPIError {
  String code;
  String message;
  String uri;

  GithubAPIError({this.code, this.message, this.uri});

  GithubAPIError.parse(dynamic json) {
    code = json['error'];
    message = json['error_description'];
    uri = json['error_uri'];
  }

  /// Returns the current instance as a [Map].
  Map<String, dynamic> get asMap {
    return <String, dynamic>{
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return '$GithubAPIError(${asMap.toString()})';
  }
}
