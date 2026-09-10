/// Helpers for compass bearings, expressed in degrees clockwise from North.
abstract final class QiblaAngle {
  /// Normalizes an angle to [0, 360).
  static double normalize(double angle) {
    final normalized = angle % 360.0;
    return normalized < 0 ? normalized + 360.0 : normalized;
  }

  /// Returns the shortest signed turn from [current] to [target].
  /// The result is in [-180, 180]. Positive values turn clockwise.
  static double shortestDifference(double target, double current) {
    final difference = normalize(target - current);
    return difference > 180.0 ? difference - 360.0 : difference;
  }
}
