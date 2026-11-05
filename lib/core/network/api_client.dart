import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_response_mapper.dart';

export 'api_response_mapper.dart' show JsonMap;

/// Secure token storage for the whole app; overridden in tests.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

/// The shared HTTP client; overridden in tests.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(tokenStorageProvider)),
);

/// Thin JSON client for the Mergro API. Adds the bearer token, and turns
/// every failure into an `ApiException` (see [ApiResponseMapper]).
class ApiClient {
  /// Creates a client; pass [dio] to stub the transport in tests.
  ApiClient(this._tokenStorage, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = ApiConfig.connectTimeout
      ..sendTimeout = ApiConfig.transferTimeout
      ..receiveTimeout = ApiConfig.transferTimeout
      ..contentType = Headers.jsonContentType
      ..responseType = ResponseType.json
      // Status codes are mapped by ApiResponseMapper, not thrown by Dio.
      ..validateStatus = (_) => true;
    _dio.interceptors.add(InterceptorsWrapper(onRequest: _addAuthorization));
  }

  final TokenStorage _tokenStorage;
  final Dio _dio;

  /// GET [path] with optional [query] parameters.
  Future<JsonMap> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  /// POST [body] as JSON to [path].
  Future<JsonMap> post(
    String path, {
    Object? body,
    Map<String, Object?>? query,
  }) =>
      _send(() => _dio.post<Object?>(path, data: body, queryParameters: query));

  /// PUT [body] as JSON to [path].
  Future<JsonMap> put(String path, {Object? body}) =>
      _send(() => _dio.put<Object?>(path, data: body));

  /// Runs [request] and maps its response or transport error.
  Future<JsonMap> _send(Future<Response<Object?>> Function() request) async {
    final Response<Object?> response;
    try {
      response = await request();
    } on DioException catch (error) {
      throw ApiResponseMapper.fromDioException(error);
    }
    return ApiResponseMapper.toJson(response);
  }

  /// Adds `Authorization: Bearer <token>` when signed in.
  Future<void> _addAuthorization(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
