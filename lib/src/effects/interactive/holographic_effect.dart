import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A holographic effect painter that creates rainbow hologram with viewing angle.
/// 
/// This effect creates a rainbow holographic appearance that changes based
/// on viewing angle and time. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: HolographicEffect(
///     viewingAngle: 0.5,
///     intensity: 0.8,
///     speed: 1.0,
///   ),
/// )
/// ```
class HolographicEffect extends BaseShaderPainter {
  /// Creates a holographic effect painter.
  /// 
  /// [viewingAngle] is the viewing angle (0.0 to 1.0).
  /// [intensity] controls the holographic intensity (0.0 to 1.0).
  /// [speed] controls the animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  HolographicEffect({
    this.viewingAngle = 0.5,
    this.intensity = 0.8,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'holographic.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Viewing angle (0.0 to 1.0).
  final double viewingAngle;

  /// Holographic intensity (0.0 to 1.0).
  final double intensity;

  /// Animation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintHolographicEffect(canvas, size);
  }

  /// Paints the holographic effect.
  void _paintHolographicEffect(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Paint holographic base
    _paintHolographicBase(canvas, size, center, time);
    
    // Paint rainbow interference patterns
    _paintInterferencePatterns(canvas, size, center, time);
    
    // Paint holographic scan lines
    _paintScanLines(canvas, size, time);
    
    // Paint viewing angle effects
    _paintViewingAngleEffects(canvas, size, center, time);
  }

  /// Paints the holographic base.
  void _paintHolographicBase(Canvas canvas, Size size, Offset center, double time) {
    final maxRadius = min(size.width, size.height) * 0.8;
    
    // Create holographic gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.cyan.withOpacity(0.1 * intensity),
        const Color(0xFFFF00FF).withOpacity(0.2 * intensity),
        Colors.yellow.withOpacity(0.1 * intensity),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: center,
          width: maxRadius * 2,
          height: maxRadius * 2,
        ),
      );
    
    canvas.drawCircle(center, maxRadius, paint);
  }

  /// Paints rainbow interference patterns.
  void _paintInterferencePatterns(Canvas canvas, Size size, Offset center, double time) {
    final patternCount = 5;
    final maxRadius = min(size.width, size.height) * 0.6;
    
    for (int i = 0; i < patternCount; i++) {
      final angle = (i / patternCount) * 2 * pi + time * 0.5;
      final radius = maxRadius * (0.3 + (i / patternCount) * 0.7);
      
      // Create rainbow color
      final hue = (i / patternCount + time * 0.1) % 1.0;
      final color = HSVColor.fromAHSV(1.0, hue * 360.0, 0.8, 1.0).toColor();
      
      // Create interference ring
      final paint = Paint()
        ..color = color.withOpacity(intensity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  /// Paints holographic scan lines.
  void _paintScanLines(Canvas canvas, Size size, double time) {
    final lineSpacing = 4.0;
    final lineCount = (size.height / lineSpacing).round();
    
    for (int i = 0; i < lineCount; i++) {
      final y = i * lineSpacing;
      final lineProgress = (y / size.height + time * 0.5) % 1.0;
      final opacity = (sin(lineProgress * 2 * pi) + 1.0) / 2.0 * intensity * 0.2;
      
      if (opacity > 0.01) {
        final paint = Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..strokeWidth = 1.0;
        
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  /// Paints viewing angle effects.
  void _paintViewingAngleEffects(Canvas canvas, Size size, Offset center, double time) {
    final maxRadius = min(size.width, size.height) * 0.4;
    
    // Calculate viewing angle offset
    final angleOffset = viewingAngle * 2 * pi;
    final viewRadius = maxRadius * 0.8;
    
    // Paint viewing angle highlight
    final highlightAngle = angleOffset + time * 0.3;
    final highlightPoint = center + Offset(
      cos(highlightAngle) * viewRadius,
      sin(highlightAngle) * viewRadius,
    );
    
    // Create highlight gradient
    final highlightGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.3,
      colors: [
        Colors.white.withOpacity(intensity * 0.8),
        Colors.cyan.withOpacity(intensity * 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final highlightPaint = Paint()
      ..shader = highlightGradient.createShader(
        Rect.fromCenter(
          center: highlightPoint,
          width: 100,
          height: 100,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(highlightPoint, 50, highlightPaint);
    
    // Paint viewing angle lines
    _paintViewingLines(canvas, size, center, angleOffset, time);
  }

  /// Paints viewing angle lines.
  void _paintViewingLines(Canvas canvas, Size size, Offset center, double angleOffset, double time) {
    final lineCount = 3;
    final maxRadius = min(size.width, size.height) * 0.6;
    
    for (int i = 0; i < lineCount; i++) {
      final angle = angleOffset + (i / lineCount) * pi / 4;
      final endPoint = center + Offset(
        cos(angle) * maxRadius,
        sin(angle) * maxRadius,
      );
      
      // Create rainbow gradient for line
      final gradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment.centerLeft,
        colors: [
          Colors.red.withOpacity(intensity * 0.6),
          Colors.green.withOpacity(intensity * 0.6),
          Colors.blue.withOpacity(intensity * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.33, 0.66, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromPoints(center, endPoint))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HolographicEffect oldDelegate) {
    return viewingAngle != oldDelegate.viewingAngle ||
           intensity != oldDelegate.intensity ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 