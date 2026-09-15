import 'package:dio/dio.dart';
import 'package:nidaa_v2/core/error/failuer.dart';

/// Translates low level [DioException]s into the project's [Failure] type.
///
/// This keeps networking details from leaking into repositories and beyond
/// while preserving the existing Clean Architecture error structure.
class DioErrorMapper {
  const DioErrorMapper._();

  /// Maps a [DioException] to a user facing [Failure].
  ///
  /// [fallbackMessage] is returned for situations where a specific message
  /// cannot be derived.
  static Failure toFailure(
    DioException error, {
    String fallbackMessage = 'Something went wrong while contacting the server',
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure('The connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badCertificate:
        return const Failure('The server certificate could not be verified.');
      case DioExceptionType.cancel:
        return const Failure('The request was cancelled.');
      case DioExceptionType.badResponse:
        return Failure(_messageForStatus(error.response?.statusCode));
      case DioExceptionType.unknown:
        return Failure(fallbackMessage);
      default:
        // Handles any future DioExceptionType values safely.
        return Failure(fallbackMessage);
    }
  }

  static String _messageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'The request was invalid.';
      case 401:
      case 403:
        return 'You are not authorized to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'The server is currently unavailable. Please try again later.';
        }
        return 'Something went wrong while contacting the server';
    }
  }
}
