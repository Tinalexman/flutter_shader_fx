import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A ripple effect painter that creates touch ripple expanding from interaction point.
/// 
/// This effect creates expanding ripple waves that emanate from touch points
/// with realistic wave physics. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: RippleEffect(
///     touchPosition: Offset(0.5, 0.5),
///     progress: 0.7,
///     rippleColor: Colors.blue,
///   ),
/// )
/// ```
class RippleEffect extends BaseShaderPainter {
  /// Creates a ripple effect painter.
  /// 
  /// [touchPosition] is the touch position (normalized coordinates).
  /// [progress] is the ripple progress (0.0 to 1.0).
  /// [rippleColor] is the color of the ripple waves.
  /// [speed] controls the ripple animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  RippleEffect({
    this.touchPosition = const Offset(0.5, 0.5),
    this.progress = 0.0,
    this.rippleColor = Colors.blue,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'ripple.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Touch position (normalized coordinates).
  final Offset touchPosition;

  /// Ripple progress (0.0 to 1.0).
  final double progress;

  /// Color of the ripple waves.
  final Color rippleColor;

  /// Ripple animation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRippleEffect(canvas, size);
  }

  /// Paints the ripple effect.
  void _paintRippleEffect(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    final center = Offset(
      touchPosition.dx * size.width,
      touchPosition.dy * size.height,
    );
    
    // Paint multiple ripple rings
    _paintRippleRings(canvas, size, center, time);
    
    // Paint ripple particles
    _paintRippleParticles(canvas, size, center, time);
    
    // Paint touch point
    _paintTouchPoint(canvas, size, center, time);
  }

  /// Paints multiple ripple rings.
  void _paintRippleRings(Canvas canvas, Size size, Offset center, double time) {
    final ringCount = 3;
    final maxRadius = min(size.width, size.height) * 0.8;
    
    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress + time * 0.5 + i * 0.2) % 1.0;
      final ringRadius = maxRadius * ringProgress;
      final ringOpacity = (1.0 - ringProgress) * 0.6;
      
      if (ringOpacity > 0.01) {
        // Create ripple ring
        final paint = Paint()
          ..color = rippleColor.withOpacity(ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * (1.0 - ringProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        canvas.drawCircle(center, ringRadius, paint);
        
        // Create secondary ring with offset
        final secondaryPaint = Paint()
          ..color = rippleColor.withOpacity(ringOpacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - ringProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        
        canvas.drawCircle(center, ringRadius + 5.0, secondaryPaint);
      }
    }
  }

  /// Paints ripple particles.
  void _paintRippleParticles(Canvas canvas, Size size, Offset center, double time) {
    final particleCount = 12;
    final maxRadius = min(size.width, size.height) * 0.6;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + time * 0.5;
      final particleProgress = (progress + time * 0.3) % 1.0;
      final particleRadius = maxRadius * particleProgress;
      
      final particlePos = center + Offset(
        cos(angle) * particleRadius,
        sin(angle) * particleRadius,
      );
      
      final particleOpacity = (1.0 - particleProgress) * 0.8;
      
      if (particleOpacity > 0.01) {
        // Create particle glow
        final glowPaint = Paint()
          ..color = rippleColor.withOpacity(particleOpacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawCircle(particlePos, 6.0, glowPaint);
        
        // Create particle core
        final corePaint = Paint()
          ..color = rippleColor.withOpacity(particleOpacity);
        
        canvas.drawCircle(particlePos, 3.0, corePaint);
      }
    }
  }

  /// Paints the touch point.
  void _paintTouchPoint(Canvas canvas, Size size, Offset center, double time) {
    final touchOpacity = (1.0 - progress) * 0.9;
    
    if (touchOpacity > 0.01) {
      // Create touch point glow
      final glowPaint = Paint()
        ..color = rippleColor.withOpacity(touchOpacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(center, 20.0, glowPaint);
      
      // Create touch point core
      final corePaint = Paint()
        ..color = rippleColor.withOpacity(touchOpacity);
      
      canvas.drawCircle(center, 8.0, corePaint);
      
      // Create pulsing effect
      final pulseOpacity = touchOpacity * (0.5 + 0.5 * sin(time * 4));
      final pulsePaint = Paint()
        ..color = rippleColor.withOpacity(pulseOpacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, 15.0, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RippleEffect oldDelegate) {
    return touchPosition != oldDelegate.touchPosition ||
           progress != oldDelegate.progress ||
           rippleColor != oldDelegate.rippleColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 