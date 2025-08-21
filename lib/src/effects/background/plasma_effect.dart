import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A plasma effect painter that creates flowing, organic color patterns.
/// 
/// This effect simulates plasma-like flowing colors using mathematical
/// functions to create smooth, animated gradients. Currently uses a
/// gradient fallback since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: PlasmaEffect(
///     colors: [Colors.purple, Colors.cyan],
///     speed: 1.0,
///     intensity: 0.8,
///   ),
/// )
/// ```
class PlasmaEffect extends BaseShaderPainter {
  /// Creates a plasma effect painter.
  /// 
  /// [colors] are the colors to use for the plasma effect.
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  PlasmaEffect({
    required this.colors,
    this.speed = 1.0,
    this.intensity = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'plasma.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Colors for the plasma effect.
  final List<Color> colors;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a gradient fallback
    _paintPlasmaGradient(canvas, size);
  }

  /// Paints a plasma-like gradient effect.
  void _paintPlasmaGradient(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Create a complex gradient that simulates plasma
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;
    
    // Create multiple gradient stops for a more complex effect
    final stops = <double>[];
    final gradientColors = <Color>[];
    
    // Add base colors
    for (int i = 0; i < colors.length; i++) {
      stops.add(i / (colors.length - 1));
      gradientColors.add(colors[i]);
    }
    
    // Add intermediate colors for smoother transitions
    if (colors.length >= 2) {
      for (int i = 0; i < colors.length - 1; i++) {
        final t = (i + 0.5) / (colors.length - 1);
        stops.add(t);
        gradientColors.add(Color.lerp(colors[i], colors[i + 1], 0.5)!);
      }
    }
    
    // Sort stops and colors together
    final pairs = <MapEntry<double, Color>>[];
    for (int i = 0; i < stops.length; i++) {
      pairs.add(MapEntry(stops[i], gradientColors[i]));
    }
    pairs.sort((a, b) => a.key.compareTo(b.key));
    
    final sortedStops = pairs.map((e) => e.key).toList();
    final sortedColors = pairs.map((e) => e.value).toList();
    
    // Create radial gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: sortedColors,
      stops: sortedStops,
    );
    
    // Apply intensity by adjusting opacity
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..color = Colors.white.withOpacity(intensity);
    
    // Draw the gradient
    canvas.drawRect(Offset.zero & size, paint);
    
    // Add some animated elements to simulate plasma movement
    _paintPlasmaOrbs(canvas, size, time);
  }

  /// Paints animated plasma orbs for additional visual interest.
  void _paintPlasmaOrbs(Canvas canvas, Size size, double time) {
    final orbCount = 3;
    final orbRadius = size.width * 0.1;
    
    for (int i = 0; i < orbCount; i++) {
      final angle = (time * 0.5 + i * 2 * 3.14159 / orbCount) % (2 * 3.14159);
      final distance = size.width * 0.3;
      
      final x = size.width / 2 + cos(angle) * distance;
      final y = size.height / 2 + sin(angle) * distance;
      
      final orbColor = colors[i % colors.length].withOpacity(0.3 * intensity);
      
      // Create a glowing orb effect
      final paint = Paint()
        ..color = orbColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      
      canvas.drawCircle(Offset(x, y), orbRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlasmaEffect oldDelegate) {
    return colors != oldDelegate.colors ||
           speed != oldDelegate.speed ||
           intensity != oldDelegate.intensity ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 