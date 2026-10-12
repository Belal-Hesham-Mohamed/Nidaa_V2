import 'package:dio/dio.dart';
import 'package:nidaa_v2/core/config/app_config.dart';
import 'package:nidaa_v2/core/network/dio_interceptors.dart';

/// Builds and configures the single Dio instance used by the whole app.
///
/// Shared networking behavior (headers, timeouts, logging, authentication,
/// and retries) is defined here. Features set a base URL when they need one.
class AppDio {
  const AppDio._();

  /// Creates the shared, fully configured [Dio] client.
  ///
  /// [tokenProvider] supplies the auth token through [AuthInterceptor] and
  /// defaults to an anonymous provider when no authentication feature exists.
  static Dio create({AuthTokenProvider? tokenProvider}) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: AppConfig.connectTimeout,
        sendTimeout: AppConfig.sendTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenProvider ?? const NoAuthTokenProvider()),
      AppLogInterceptor(),
      // Retry is added last so it observes errors from the whole chain.
      // It reuses this same instance, avoiding duplicate Dio clients.
      RetryInterceptor(
        dio: dio,
        maxAttempts: AppConfig.maxRetryAttempts,
        initialDelay: AppConfig.retryInitialDelay,
      ),
    ]);
    //this
    return dio;
  }
}
