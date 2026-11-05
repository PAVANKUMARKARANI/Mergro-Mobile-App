import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_client.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';

import '../../helpers/fakes.dart';

/// Answers every request with [status] and [body], or throws [error].
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.status = 200, this.body = const {}, this.error});

  final int status;
  final Object body;
  final DioExceptionType? error;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (error case final type?) {
      throw DioException(requestOptions: options, type: type);
    }
    return ResponseBody.fromString(
      body is String ? body as String : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A client whose transport is [adapter], signed in with [token].
ApiClient _client(_StubAdapter adapter, {String? token}) {
  final storage = InMemoryTokenStorage()..token = token;
  return ApiClient(storage, dio: Dio()..httpClientAdapter = adapter);
}

/// The kind of [ApiException] thrown by [call].
Future<ApiErrorKind> _kindOf(Future<Object?> call) async {
  try {
    await call;
  } on ApiException catch (error) {
    return error.kind;
  }
  fail('expected an ApiException');
}

void main() {
  test('sends the bearer token and returns the JSON body', () async {
    final adapter = _StubAdapter(body: {'respCode': 200, 'details': 1});
    final json = await _client(adapter, token: 'abc').get('/auth/me');

    expect(json['details'], 1);
    expect(adapter.lastRequest?.headers['Authorization'], 'Bearer abc');
  });

  test('omits Authorization when signed out', () async {
    final adapter = _StubAdapter();
    await _client(adapter).post('/auth/login', body: {'email': 'a@b.co'});
    expect(adapter.lastRequest?.headers.containsKey('Authorization'), isFalse);
  });

  test('the template error shape (HTTP 200 + errorCode) is a validation '
      'error carrying the server message', () async {
    final adapter = _StubAdapter(
      body: {'errorCode': '9001', 'errorMessage': 'Invalid password.'},
    );
    try {
      await _client(adapter).post('/auth/login');
      fail('expected an ApiException');
    } on ApiException catch (error) {
      expect(error.kind, ApiErrorKind.validation);
      expect(error.message, 'Invalid password.');
    }
  });

  test('sessionExpired and 401 both mean unauthorized', () async {
    final flagged = _StubAdapter(
      body: {'errorCode': '9001', 'sessionExpired': true},
    );
    expect(
      await _kindOf(_client(flagged).get('/x')),
      ApiErrorKind.unauthorized,
    );
    expect(
      await _kindOf(_client(_StubAdapter(status: 401)).get('/x')),
      ApiErrorKind.unauthorized,
    );
  });

  test('HTTP 400 reads express-validator messages', () async {
    final adapter = _StubAdapter(
      status: 400,
      body: {
        'errors': [
          {'msg': 'Please provide email'},
        ],
      },
    );
    try {
      await _client(adapter).post('/auth/login');
      fail('expected an ApiException');
    } on ApiException catch (error) {
      expect(error.kind, ApiErrorKind.validation);
      expect(error.message, 'Please provide email');
    }
  });

  test('maps status codes and transport failures', () async {
    Future<ApiErrorKind> kindFor(_StubAdapter adapter) =>
        _kindOf(_client(adapter).get('/x'));

    expect(await kindFor(_StubAdapter(status: 403)), ApiErrorKind.forbidden);
    expect(await kindFor(_StubAdapter(status: 404)), ApiErrorKind.notFound);
    expect(await kindFor(_StubAdapter(status: 502)), ApiErrorKind.server);
    expect(
      await kindFor(_StubAdapter(body: 'not json')),
      ApiErrorKind.unexpected,
    );
    expect(
      await kindFor(_StubAdapter(error: DioExceptionType.connectionError)),
      ApiErrorKind.network,
    );
    expect(
      await kindFor(_StubAdapter(error: DioExceptionType.receiveTimeout)),
      ApiErrorKind.timeout,
    );
  });

  test('every kind has a friendly default message', () {
    for (final kind in ApiErrorKind.values) {
      expect(ApiException(kind).message, isNotEmpty);
    }
    expect(ApiException(ApiErrorKind.network).isTransient, isTrue);
    expect(ApiException(ApiErrorKind.validation).isTransient, isFalse);
  });
}
