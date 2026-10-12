/// Centralized application level configuration.
///
/// This is the single source of truth for values shared by the networking
/// infrastructure that remains available to app features.
class AppConfig {
  const AppConfig._();

  /// Timeouts applied centrally to the shared Dio instance.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Retry behaviour for transient network/server failures.
  static const int maxRetryAttempts = 3;
  static const Duration retryInitialDelay = Duration(milliseconds: 500);
}
