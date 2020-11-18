/// The status after a [FlutterAuthLogin] flow has completed.
enum FlutterAuthExceptionCode {
  /// There was an error during the login process
  login,

  /// The request was cancelled by the user
  cancelled,

  /// Indicates a network error occurred.
  network,

  /// The request was denied.
  denied,
}
