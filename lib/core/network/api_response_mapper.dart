import 'package:dio/dio.dart';

import '../utils/app_logger.dart';
import 'api_exception.dart';

/// JSON object as decoded from an API response.
typedef JsonMap = Map<String, dynamic>;

/// Turns raw responses and transport errors into a [JsonMap] or an
/// [ApiException].
///
/// The backend template answers most failures with HTTP 200 and
/// `{errorCode: "9001", errorMessage}`; expired sessions also carry
/// `sessionExpired: true`. Request-validation failures are HTTP 400 with
/// `{errors: [{msg}]}`.
abstract final class ApiResponseMapper {
  /// Returns the JSON body of a successful response, or throws.
  static JsonMap toJson(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;
    final json = body is Map<String, dynamic> ? body : null;
    final path = response.requestOptions.path;

    if (status == 401 || json?['sessionExpired'] == true) {
      throw _fail(ApiErrorKind.unauthorized, path, status);
    }
    if (status == 403) {
      throw _fail(ApiErrorKind.forbidden, path, status, _messageOf(json));
    }
    if (status == 404) {
      throw _fail(ApiErrorKind.notFound, path, status, _messageOf(json));
    }
    if (status >= 500) throw _fail(ApiErrorKind.server, path, status);
    if (status == 400 || status == 422) {
      throw _fail(ApiErrorKind.validation, path, status, _messageOf(json));
    }
    if (json == null || status < 200 || status >= 300) {
      throw _fail(ApiErrorKind.unexpected, path, status);
    }
    if (json['errorCode'] != null) {
      throw _fail(ApiErrorKind.validation, path, status, _messageOf(json));
    }
    return json;
  }

  /// Maps a transport-level failure (no usable response) to an exception.
  static ApiException fromDioException(DioException error) {
    // A body that isn't valid JSON arrives as `unknown` wrapping a
    // FormatException: the server answered, so it is not a network problem.
    final isDecodeError = error.error is FormatException;
    final kind = isDecodeError ? ApiErrorKind.unexpected : _kindOf(error.type);
    return _fail(kind, error.requestOptions.path, null, null, error.type);
  }

  /// Error kind for a transport-level failure type.
  static ApiErrorKind _kindOf(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiErrorKind.timeout,
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      // Socket errors surface as `unknown` on some platforms.
      DioExceptionType.unknown => ApiErrorKind.network,
      DioExceptionType.badResponse ||
      DioExceptionType.cancel => ApiErrorKind.unexpected,
    };
  }

  /// Reads the server's user-facing message from either error shape.
  static String? _messageOf(JsonMap? json) {
    final errorMessage = json?['errorMessage'];
    if (errorMessage is String) return errorMessage;
    final errors = json?['errors'];
    if (errors is List && errors.isNotEmpty && errors.first is Map) {
      final message = (errors.first as Map)['msg'];
      if (message is String) return message;
    }
    return null;
  }

  /// Logs the failure (path and status only, never data) and builds it.
  static ApiException _fail(
    ApiErrorKind kind,
    String path,
    int? status, [
    String? message,
    Object? cause,
  ]) {
    AppLogger.warning('API ${kind.name} on $path (status: $status)', cause);
    return ApiException(kind, message: message, statusCode: status);
  }
}
