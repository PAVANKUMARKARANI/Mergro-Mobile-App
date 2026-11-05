/// The kinds of failure every API call is mapped to (standards A10).
enum ApiErrorKind {
  /// No connection, DNS failure or connection refused.
  network,

  /// The server did not answer in time.
  timeout,

  /// The session is missing or expired (HTTP 401 or `sessionExpired`).
  unauthorized,

  /// The user may not do this (HTTP 403).
  forbidden,

  /// The resource does not exist (HTTP 404).
  notFound,

  /// The server rejected the input; [ApiException.message] says why.
  validation,

  /// The server failed (HTTP 5xx).
  server,

  /// Anything else, such as a malformed response.
  unexpected,
}

/// A failed API call. [message] is always safe to show to the user.
class ApiException implements Exception {
  /// Creates an exception; [message] defaults to the kind's generic text.
  ApiException(this.kind, {String? message, this.statusCode})
    : message = (message == null || message.trim().isEmpty)
          ? defaultMessages[kind]!
          : message;

  /// What went wrong.
  final ApiErrorKind kind;

  /// User-facing explanation.
  final String message;

  /// HTTP status, when there was a response.
  final int? statusCode;

  /// Generic user-facing text per kind.
  static const Map<ApiErrorKind, String> defaultMessages = {
    ApiErrorKind.network:
        "Can't reach Mergro. Check your internet connection and try again.",
    ApiErrorKind.timeout: 'Mergro is taking too long to respond. Try again.',
    ApiErrorKind.unauthorized: 'Your session has expired. Sign in again.',
    ApiErrorKind.forbidden: "You don't have permission to do that.",
    ApiErrorKind.notFound: "We couldn't find what you were looking for.",
    ApiErrorKind.validation: 'Check the details and try again.',
    ApiErrorKind.server: 'Something went wrong on our side. Try again soon.',
    ApiErrorKind.unexpected: 'Something unexpected happened. Try again.',
  };

  /// True when retrying later might succeed (connectivity or server trouble).
  bool get isTransient =>
      kind == ApiErrorKind.network ||
      kind == ApiErrorKind.timeout ||
      kind == ApiErrorKind.server;

  /// Debug description; never contains request data.
  @override
  String toString() => 'ApiException(${kind.name}, status: $statusCode)';
}
