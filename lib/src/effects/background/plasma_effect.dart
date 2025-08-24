import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A plasma effect painter that creates flowing, organic color patterns.
/// 
/// This effect simulates plasma-like flowing colors using mathematical
/// functions to create smooth, animated gradients.
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
    this.touchPosition = const Offset(0.5, 0.5),
    PerformanceLevel? performanceLevel,
  }) : super(
          shaderPath: 'plasma.frag',
          uniforms: {
            'u_intensity': intensity,
            'u_color1': colors.isNotEmpty ? colors[0] : const Color(0xFF9C27B0),
            'u_color2': colors.length > 1 ? colors[1] : const Color(0xFF00BCD4),
            'u_speed': speed,
          },
          performanceLevel: performanceLevel ?? PerformanceLevel.medium,
        );

  /// Colors for the plasma effect.
  final List<Color> colors;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  /// Touch/mouse position for interaction (normalized 0.0-1.0).
  final Offset touchPosition;

  @override
  Offset getTouchPosition() {
    return touchPosition;
  }

  @override
  void setCustomUniforms(FragmentShader shader, int startIndex) {
    // Set speed uniform
    shader.setFloat(startIndex, speed);
    
    // Add additional colors if more than 2
    if (colors.length > 2) {
      int colorIndex = startIndex + 1;
      for (int i = 2; i < colors.length && i < 6; i++) {
        final color = colors[i];
        shader.setFloat(colorIndex++, color.r);
        shader.setFloat(colorIndex++, color.g);
        shader.setFloat(colorIndex++, color.b);
        shader.setFloat(colorIndex++, color.a);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isShaderLoaded) {
      // Use shader if available
      super.paint(canvas, size);
    } else {
      // Fallback to gradient implementation
      _paintPlasmaGradient(canvas, size);
    }
  }

  /// Paints a plasma-like gradient effect as fallback.
  void _paintPlasmaGradient(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Create multiple overlapping gradients for plasma effect
    _paintPlasmaLayer(canvas, size, time, 0.0);
    _paintPlasmaLayer(canvas, size, time * 0.7, 0.3);
    _paintPlasmaLayer(canvas, size, time * 1.3, 0.6);
    
    // Add animated orbs for extra visual interest
    _paintPlasmaOrbs(canvas, size, time);
  }

  /// Paints a single plasma layer.
  void _paintPlasmaLayer(Canvas canvas, Size size, double time, double phase) {
    final centerX = size.width * (0.5 + 0.3 * sin(time + phase));
    final centerY = size.height * (0.5 + 0.2 * cos(time * 0.8 + phase));
    final center = Offset(centerX, centerY);
    
    final radius = size.width * (0.6 + 0.2 * sin(time * 0.5 + phase));
    
    // Create colors for this layer
    final layerColors = <Color>[];
    final stops = <double>[];
    
    for (int i = 0; i < colors.length; i++) {
      final t = (i / (colors.length - 1) + phase) % 1.0;
      stops.add(t);
      layerColors.add(colors[i].withOpacity(intensity * 0.4));
    }
    
    // Sort stops and colors
    final pairs = List.generate(stops.length, (i) => MapEntry(stops[i], layerColors[i]));
    pairs.sort((a, b) => a.key.compareTo(b.key));
    
    final gradient = RadialGradient(
      center: Alignment(
        (center.dx / size.width) * 2 - 1,
        (center.dy / size.height) * 2 - 1,
      ),
      radius: radius / (size.width * 0.5),
      colors: pairs.map((e) => e.value).toList(),
      stops: pairs.map((e) => e.key).toList(),
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..blendMode = BlendMode.screen;
    
    canvas.drawRect(Offset.zero & size, paint);
  }

  /// Paints animated plasma orbs for additional visual interest.
  void _paintPlasmaOrbs(Canvas canvas, Size size, double time) {
    final orbCount = min(colors.length, 4);
    
    for (int i = 0; i < orbCount; i++) {
      final angle = (time * (0.3 + i * 0.1) + i * 2 * pi / orbCount) % (2 * pi);
      final distance = size.width * (0.2 + 0.1 * sin(time * 0.7 + i));
      final orbRadius = size.width * (0.05 + 0.03 * sin(time + i));
      
      final x = size.width / 2 + cos(angle) * distance;
      final y = size.height / 2 + sin(angle) * distance;
      
      final orbColor = colors[i % colors.length].withOpacity(0.6 * intensity);
      
      // Create gradient for orb
      final orbGradient = RadialGradient(
        colors: [
          orbColor,
          orbColor.withOpacity(0.3),
          orbColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      
      final orbPaint = Paint()
        ..shader = orbGradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: orbRadius),
        )
        ..blendMode = BlendMode.plus;
      
      canvas.drawCircle(Offset(x, y), orbRadius, orbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlasmaEffect oldDelegate) {
    return colors != oldDelegate.colors ||
           speed != oldDelegate.speed ||
           intensity != oldDelegate.intensity ||
           touchPosition != oldDelegate.touchPosition ||
           super.shouldRepaint(oldDelegate);
  }
}