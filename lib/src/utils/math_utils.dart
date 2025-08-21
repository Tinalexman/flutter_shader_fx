import 'dart:math' as math;

/// Utility functions for mathematical operations used in shader effects.
/// 
/// This class provides helper functions for common mathematical operations
/// needed in shader effects, including interpolation, noise, and geometric calculations.
class MathUtils {
  /// Private constructor to prevent instantiation.
  MathUtils._();

  /// Clamps a value between min and max.
  /// 
  /// [value] is the value to clamp.
  /// [min] is the minimum value.
  /// [max] is the maximum value.
  /// Returns the clamped value.
  static double clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  /// Linearly interpolates between two values.
  /// 
  /// [a] is the first value.
  /// [b] is the second value.
  /// [t] is the interpolation factor (0.0 to 1.0).
  /// Returns the interpolated value.
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Smoothly interpolates between two values using smoothstep.
  /// 
  /// [a] is the first value.
  /// [b] is the second value.
  /// [t] is the interpolation factor (0.0 to 1.0).
  /// Returns the smoothly interpolated value.
  static double smoothstep(double a, double b, double t) {
    final x = t.clamp(0.0, 1.0);
    return a + (b - a) * (3.0 * x * x - 2.0 * x * x * x);
  }

  /// Converts degrees to radians.
  /// 
  /// [degrees] is the angle in degrees.
  /// Returns the angle in radians.
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Converts radians to degrees.
  /// 
  /// [radians] is the angle in radians.
  /// Returns the angle in degrees.
  static double radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Calculates the distance between two 2D points.
  /// 
  /// [x1] is the x coordinate of the first point.
  /// [y1] is the y coordinate of the first point.
  /// [x2] is the x coordinate of the second point.
  /// [y2] is the y coordinate of the second point.
  /// Returns the distance between the points.
  static double distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculates the squared distance between two 2D points.
  /// 
  /// This is faster than distance() when you only need to compare distances.
  /// [x1] is the x coordinate of the first point.
  /// [y1] is the y coordinate of the first point.
  /// [x2] is the x coordinate of the second point.
  /// [y2] is the y coordinate of the second point.
  /// Returns the squared distance between the points.
  static double distanceSquared(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return dx * dx + dy * dy;
  }

  /// Calculates the length of a 2D vector.
  /// 
  /// [x] is the x component of the vector.
  /// [y] is the y component of the vector.
  /// Returns the length of the vector.
  static double length(double x, double y) {
    return math.sqrt(x * x + y * y);
  }

  /// Normalizes a 2D vector.
  /// 
  /// [x] is the x component of the vector.
  /// [y] is the y component of the vector.
  /// Returns a list [normalizedX, normalizedY].
  static List<double> normalize(double x, double y) {
    final len = length(x, y);
    if (len == 0.0) return [0.0, 0.0];
    return [x / len, y / len];
  }

  /// Calculates the dot product of two 2D vectors.
  /// 
  /// [x1] is the x component of the first vector.
  /// [y1] is the y component of the first vector.
  /// [x2] is the x component of the second vector.
  /// [y2] is the y component of the second vector.
  /// Returns the dot product.
  static double dot(double x1, double y1, double x2, double y2) {
    return x1 * x2 + y1 * y2;
  }

  /// Calculates the cross product of two 2D vectors.
  /// 
  /// [x1] is the x component of the first vector.
  /// [y1] is the y component of the first vector.
  /// [x2] is the x component of the second vector.
  /// [y2] is the y component of the second vector.
  /// Returns the cross product (scalar).
  static double cross(double x1, double y1, double x2, double y2) {
    return x1 * y2 - y1 * x2;
  }

  /// Maps a value from one range to another.
  /// 
  /// [value] is the value to map.
  /// [fromMin] is the minimum of the source range.
  /// [fromMax] is the maximum of the source range.
  /// [toMin] is the minimum of the target range.
  /// [toMax] is the maximum of the target range.
  /// Returns the mapped value.
  static double mapRange(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
  }

  /// Wraps a value to a range.
  /// 
  /// [value] is the value to wrap.
  /// [min] is the minimum of the range.
  /// [max] is the maximum of the range.
  /// Returns the wrapped value.
  static double wrap(double value, double min, double max) {
    final range = max - min;
    if (range == 0.0) return min;
    
    final wrapped = (value - min) % range;
    return wrapped < 0.0 ? wrapped + max : wrapped + min;
  }

  /// Calculates the modulo operation that works with negative numbers.
  /// 
  /// [value] is the dividend.
  /// [divisor] is the divisor.
  /// Returns the modulo result.
  static double mod(double value, double divisor) {
    return ((value % divisor) + divisor) % divisor;
  }

  /// Calculates the fractional part of a number.
  /// 
  /// [value] is the number.
  /// Returns the fractional part (0.0 to 1.0).
  static double fract(double value) {
    return value - value.floor();
  }

  /// Calculates the integer part of a number.
  /// 
  /// [value] is the number.
  /// Returns the integer part.
  static int floor(double value) {
    return value.floor();
  }

  /// Calculates the ceiling of a number.
  /// 
  /// [value] is the number.
  /// Returns the ceiling.
  static int ceil(double value) {
    return value.ceil();
  }

  /// Rounds a number to the nearest integer.
  /// 
  /// [value] is the number.
  /// Returns the rounded value.
  static int round(double value) {
    return value.round();
  }

  /// Calculates the absolute value.
  /// 
  /// [value] is the number.
  /// Returns the absolute value.
  static double abs(double value) {
    return value.abs();
  }

  /// Calculates the sign of a number.
  /// 
  /// [value] is the number.
  /// Returns -1.0 if negative, 0.0 if zero, 1.0 if positive.
  static double sign(double value) {
    if (value > 0.0) return 1.0;
    if (value < 0.0) return -1.0;
    return 0.0;
  }

  /// Calculates the minimum of two values.
  /// 
  /// [a] is the first value.
  /// [b] is the second value.
  /// Returns the minimum value.
  static double min(double a, double b) {
    return math.min(a, b);
  }

  /// Calculates the maximum of two values.
  /// 
  /// [a] is the first value.
  /// [b] is the second value.
  /// Returns the maximum value.
  static double max(double a, double b) {
    return math.max(a, b);
  }

  /// Calculates the power of a number.
  /// 
  /// [base] is the base number.
  /// [exponent] is the exponent.
  /// Returns the result.
  static double pow(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  /// Calculates the square root of a number.
  /// 
  /// [value] is the number.
  /// Returns the square root.
  static double sqrt(double value) {
    return math.sqrt(value);
  }

  /// Calculates the sine of an angle.
  /// 
  /// [angle] is the angle in radians.
  /// Returns the sine value.
  static double sin(double angle) {
    return math.sin(angle);
  }

  /// Calculates the cosine of an angle.
  /// 
  /// [angle] is the angle in radians.
  /// Returns the cosine value.
  static double cos(double angle) {
    return math.cos(angle);
  }

  /// Calculates the tangent of an angle.
  /// 
  /// [angle] is the angle in radians.
  /// Returns the tangent value.
  static double tan(double angle) {
    return math.tan(angle);
  }

  /// Calculates the arc sine of a value.
  /// 
  /// [value] is the value (-1.0 to 1.0).
  /// Returns the angle in radians.
  static double asin(double value) {
    return math.asin(value);
  }

  /// Calculates the arc cosine of a value.
  /// 
  /// [value] is the value (-1.0 to 1.0).
  /// Returns the angle in radians.
  static double acos(double value) {
    return math.acos(value);
  }

  /// Calculates the arc tangent of a value.
  /// 
  /// [value] is the value.
  /// Returns the angle in radians.
  static double atan(double value) {
    return math.atan(value);
  }

  /// Calculates the arc tangent of y/x.
  /// 
  /// [y] is the y coordinate.
  /// [x] is the x coordinate.
  /// Returns the angle in radians.
  static double atan2(double y, double x) {
    return math.atan2(y, x);
  }

  /// Calculates the natural logarithm of a number.
  /// 
  /// [value] is the number.
  /// Returns the natural logarithm.
  static double log(double value) {
    return math.log(value);
  }

  /// Calculates the exponential of a number.
  /// 
  /// [value] is the number.
  /// Returns e raised to the power of value.
  static double exp(double value) {
    return math.exp(value);
  }
} 