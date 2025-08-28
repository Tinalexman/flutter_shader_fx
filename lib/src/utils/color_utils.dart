import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for color manipulation and conversion.
/// 
/// This class provides helper functions for working with colors in shader effects,
/// including color interpolation, conversion, and mathematical operations.
class ColorUtils {
  /// Private constructor to prevent instantiation.
  ColorUtils._();

  /// Converts a Color to a list of RGBA values (0.0 to 1.0).
  /// 
  /// [color] is the color to convert.
  /// Returns a list of [red, green, blue, alpha] values.
  static List<double> colorToRGBA(Color color) {
    return [
      color.r,
      color.g,
      color.b,
      color.a,
    ];
  }

  /// Converts a Color to a list of RGB values (0.0 to 1.0).
  /// 
  /// [color] is the color to convert.
  /// Returns a list of [red, green, blue] values.
  static List<double> colorToRGB(Color color) {
    return [
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
    ];
  }

  /// Converts a Color to HSV values.
  /// 
  /// [color] is the color to convert.
  /// Returns a list of [hue, saturation, value] values.
  /// Hue is in degrees (0-360), saturation and value are 0.0 to 1.0.
  static List<double> colorToHSV(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    final max = math.max(math.max(r, g), b);
    final min = math.min(math.min(r, g), b);
    final delta = max - min;
    
    double hue = 0.0;
    if (delta != 0.0) {
      if (max == r) {
        hue = ((g - b) / delta) % 6.0;
      } else if (max == g) {
        hue = (b - r) / delta + 2.0;
      } else {
        hue = (r - g) / delta + 4.0;
      }
      hue *= 60.0;
      if (hue < 0.0) hue += 360.0;
    }
    
    final saturation = max == 0.0 ? 0.0 : delta / max;
    final value = max;
    
    return [hue, saturation, value];
  }

  /// Converts HSV values to a Color.
  /// 
  /// [hue] is the hue in degrees (0-360).
  /// [saturation] is the saturation (0.0 to 1.0).
  /// [value] is the value (0.0 to 1.0).
  /// Returns the corresponding Color.
  static Color hsvToColor(double hue, double saturation, double value) {
    final c = value * saturation;
    final x = c * (1.0 - ((hue / 60.0) % 2.0 - 1.0).abs());
    final m = value - c;
    
    double r = 0.0, g = 0.0, b = 0.0;
    
    if (hue < 60.0) {
      r = c; g = x; b = 0.0;
    } else if (hue < 120.0) {
      r = x; g = c; b = 0.0;
    } else if (hue < 180.0) {
      r = 0.0; g = c; b = x;
    } else if (hue < 240.0) {
      r = 0.0; g = x; b = c;
    } else if (hue < 300.0) {
      r = x; g = 0.0; b = c;
    } else {
      r = c; g = 0.0; b = x;
    }
    
    return Color.fromARGB(
      255,
      ((r + m) * 255.0).round(),
      ((g + m) * 255.0).round(),
      ((b + m) * 255.0).round(),
    );
  }

  /// Interpolates between two colors.
  /// 
  /// [color1] is the first color.
  /// [color2] is the second color.
  /// [t] is the interpolation factor (0.0 to 1.0).
  /// Returns the interpolated color.
  static Color interpolateColors(Color color1, Color color2, double t) {
    return Color.lerp(color1, color2, t)!;
  }

  /// Interpolates between multiple colors.
  /// 
  /// [colors] is the list of colors to interpolate between.
  /// [t] is the interpolation factor (0.0 to 1.0).
  /// Returns the interpolated color.
  static Color interpolateMultipleColors(List<Color> colors, double t) {
    if (colors.isEmpty) return Colors.transparent;
    if (colors.length == 1) return colors.first;
    
    final segmentSize = 1.0 / (colors.length - 1);
    final segment = (t / segmentSize).floor();
    final segmentT = (t % segmentSize) / segmentSize;
    
    if (segment >= colors.length - 1) {
      return colors.last;
    }
    
    return Color.lerp(colors[segment], colors[segment + 1], segmentT)!;
  }

  /// Creates a color with adjusted brightness.
  /// 
  /// [color] is the base color.
  /// [brightness] is the brightness adjustment (-1.0 to 1.0).
  /// Returns the adjusted color.
  static Color adjustBrightness(Color color, double brightness) {
    final hsv = colorToHSV(color);
    hsv[2] = (hsv[2] + brightness).clamp(0.0, 1.0);
    return hsvToColor(hsv[0], hsv[1], hsv[2]);
  }

  /// Creates a color with adjusted saturation.
  /// 
  /// [color] is the base color.
  /// [saturation] is the saturation adjustment (-1.0 to 1.0).
  /// Returns the adjusted color.
  static Color adjustSaturation(Color color, double saturation) {
    final hsv = colorToHSV(color);
    hsv[1] = (hsv[1] + saturation).clamp(0.0, 1.0);
    return hsvToColor(hsv[0], hsv[1], hsv[2]);
  }

  /// Creates a color with adjusted hue.
  /// 
  /// [color] is the base color.
  /// [hue] is the hue adjustment in degrees.
  /// Returns the adjusted color.
  static Color adjustHue(Color color, double hue) {
    final hsv = colorToHSV(color);
    hsv[0] = (hsv[0] + hue) % 360.0;
    return hsvToColor(hsv[0], hsv[1], hsv[2]);
  }

  /// Calculates the luminance of a color.
  /// 
  /// [color] is the color to calculate luminance for.
  /// Returns the luminance value (0.0 to 1.0).
  static double calculateLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Creates a contrasting color for text on a background.
  /// 
  /// [backgroundColor] is the background color.
  /// [lightText] is the color to use for light text.
  /// [darkText] is the color to use for dark text.
  /// Returns the contrasting color.
  static Color getContrastingColor(
    Color backgroundColor, {
    Color lightText = Colors.white,
    Color darkText = Colors.black,
  }) {
    final luminance = calculateLuminance(backgroundColor);
    return luminance > 0.5 ? darkText : lightText;
  }

  /// Creates a color palette from a base color.
  /// 
  /// [baseColor] is the base color for the palette.
  /// [count] is the number of colors in the palette.
  /// Returns a list of colors forming a palette.
  static List<Color> createColorPalette(Color baseColor, int count) {
    final hsv = colorToHSV(baseColor);
    final colors = <Color>[];
    
    for (int i = 0; i < count; i++) {
      final hue = (hsv[0] + (i * 360.0 / count)) % 360.0;
      colors.add(hsvToColor(hue, hsv[1], hsv[2]));
    }
    
    return colors;
  }

  /// Creates a gradient between two colors.
  /// 
  /// [color1] is the first color.
  /// [color2] is the second color.
  /// [stops] are the gradient stops (optional).
  /// Returns a LinearGradient.
  static LinearGradient createGradient(
    Color color1,
    Color color2, {
    List<double>? stops,
  }) {
    return LinearGradient(
      colors: [color1, color2],
      stops: stops,
    );
  }

  /// Creates a radial gradient.
  /// 
  /// [center] is the center color.
  /// [edge] is the edge color.
  /// [centerAlignment] is the center alignment.
  /// [radius] is the radius of the gradient.
  /// Returns a RadialGradient.
  static RadialGradient createRadialGradient(
    Color center,
    Color edge, {
    Alignment centerAlignment = Alignment.center,
    double radius = 1.0,
  }) {
    return RadialGradient(
      center: centerAlignment,
      radius: radius,
      colors: [center, edge],
    );
  }
} 