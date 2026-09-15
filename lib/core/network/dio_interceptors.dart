import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Provides the authentication token for outgoing requests.
///
/// The concrete implementation is registered in the service locator so the
/// networking layer never depends on a concrete auth feature.
abstract class AuthTokenProvider {
  /// Returns the current access token, or `null` when the user is anonymous.
  String? getToken();
}

/// Default provider used until a real authentication feature is wired up.
///
/// It intentionally returns no token so no request is sent with a hardcoded
/// or fake credential.
class NoAuthTokenProvider implements AuthTokenProvider {
  const NoAuthTokenProvider();

  @override
  String? getToken() => null;
}

/// Adds the authentication token to every outgoing request when available.
///
/// The token is read lazily per request, so refreshing it does not require
/// rebuilding the Dio instance.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final AuthTokenProvider _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// Logs requests/responses in debug builds only.
///
/// Sensitive headers and fields (authorization, cookies, passwords, tokens)
/// are redacted so credentials never reach the logs.
class AppLogInterceptor extends Interceptor {
  AppLogInterceptor({this.enabled = kDebugMode});

  final bool enabled;

  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'proxy-authorization',
  };

  static const Set<String> _sensitiveFields = {
    'password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method} ${options.uri}');
    _log('  headers: ${_redactHeaders(options.headers)}');
    if (options.data != null) {
      _log('  body: ${_redactBody(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('✕ ${err.type.name} ${err.requestOptions.uri} → ${err.message}');
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _sensitiveHeaders.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
  }

  Object? _redactBody(Object? body) {
    if (body is Map) {
      return {
        for (final entry in body.entries)
          entry.key:
              _sensitiveFields.contains(entry.key.toString().toLowerCase())
              ? '***'
              : entry.value,
      };
    }
    return body;
  }

  void _log(String message) {
    if (enabled) {
      debugPrint('[DIO] $message');
    }
  }
}

/// Retries only transient failures (connection issues, timeouts, server
/// errors) with exponential backoff.
///
/// Client errors such as 400/401/403/404 are never retried, and the retry
/// count is bounded by [maxAttempts] so no infinite loop is possible.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  final Dio dio;
  final int maxAttempts;
  final Duration initialDelay;

  static const String _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxAttempts || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final delay = initialDelay * (1 << attempt);
    await Future<void>.delayed(delay);

    final options = err.requestOptions..extra[_attemptKey] = attempt + 1;

    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        // Retry only server-side / throttling responses. Client errors such
        // as 400/401/403/404 are never retried.
        return status == 408 || status == 429 || status >= 500;
      default:
        // Cancellations and any other (future) error types are not retried.
        return false;
    }
  }
}
