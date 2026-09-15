/// Centralized application level configuration.
///
/// This is the single source of truth for values that are shared across the
/// app (API base URL, network timeouts, ...). Feature specific endpoint paths
/// stay in [ApiConstants].
class AppConfig {
  const AppConfig._();

  /// Base URL for the remote API. Every network request goes through the
  /// Dio instance configured from this value, so it must never be repeated
  /// inside data sources or repositories.
  static const String apiBaseUrl = 'https://api.aladhan.com/v1';

  /// Timeouts applied centrally to the shared Dio instance.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Retry behaviour for transient network/server failures.
  static const int maxRetryAttempts = 3;
  static const Duration retryInitialDelay = Duration(milliseconds: 500);
}
