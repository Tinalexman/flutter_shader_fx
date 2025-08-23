import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A spiral galaxy effect painter that creates rotating spiral with progress-based intensity.
/// 
/// This effect creates a spiral galaxy that rotates and changes intensity based
/// on progress. Currently uses a simplified implementation since shader compilation
/// is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: SpiralGalaxyEffect(
///     progress: 0.7,
///     spiralColor: Colors.purple,
///     speed: 1.0,
///   ),
/// )
/// ```
class SpiralGalaxyEffect extends BaseShaderPainter {
  /// Creates a spiral galaxy effect painter.
  /// 
  /// [progress] is the progress value (0.0 to 1.0).
  /// [spiralColor] is the color of the spiral.
  /// [speed] controls the rotation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  SpiralGalaxyEffect({
    this.progress = 0.0,
    this.spiralColor = Colors.purple,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'spiral_galaxy.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Progress value (0.0 to 1.0).
  final double progress;

  /// Color of the spiral.
  final Color spiralColor;

  /// Rotation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSpiralGalaxy(canvas, size);
  }

  /// Paints the spiral galaxy effect.
  void _paintSpiralGalaxy(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Paint background
    _paintBackground(canvas, size);
    
    // Paint spiral arms
    _paintSpiralArms(canvas, size, center, time);
    
    // Paint central core
    _paintCentralCore(canvas, size, center, time);
    
    // Paint progress indicator
    _paintProgressIndicator(canvas, size, center);
  }

  /// Paints the background.
  void _paintBackground(Canvas canvas, Size size) {
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create background gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.black.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(backgroundRect);
    
    canvas.drawRect(backgroundRect, paint);
  }

  /// Paints spiral arms.
  void _paintSpiralArms(Canvas canvas, Size size, Offset center, double time) {
    final armCount = 4;
    final maxRadius = min(size.width, size.height) * 0.4;
    
    for (int arm = 0; arm < armCount; arm++) {
      final armAngle = (arm / armCount) * 2 * pi + time * 0.3;
      
      // Create spiral path
      final path = Path();
      final points = <Offset>[];
      
      for (int i = 0; i <= 50; i++) {
        final t = i / 50.0;
        final radius = maxRadius * t * progress;
        final angle = armAngle + t * 4 * pi;
        
        final x = center.dx + cos(angle) * radius;
        final y = center.dy + sin(angle) * radius;
        
        points.add(Offset(x, y));
      }
      
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
        
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        
        // Create spiral gradient
        final gradient = LinearGradient(
          begin: Alignment.center,
          end: Alignment.centerLeft,
          colors: [
            spiralColor.withOpacity(0.8 * progress),
            spiralColor.withOpacity(0.4 * progress),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        );
        
        final paint = Paint()
          ..shader = gradient.createShader(Offset.zero & size)
          ..strokeWidth = 3.0 * progress
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Paints the central core.
  void _paintCentralCore(Canvas canvas, Size size, Offset center, double time) {
    final coreRadius = min(size.width, size.height) * 0.1 * progress;
    
    // Create core glow
    final glowPaint = Paint()
      ..color = spiralColor.withOpacity(0.6 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(center, coreRadius * 2, glowPaint);
    
    // Create core
    final corePaint = Paint()
      ..color = spiralColor.withOpacity(0.9 * progress);
    
    canvas.drawCircle(center, coreRadius, corePaint);
    
    // Create rotating particles around core
    _paintCoreParticles(canvas, size, center, time);
  }

  /// Paints particles around the core.
  void _paintCoreParticles(Canvas canvas, Size size, Offset center, double time) {
    final particleCount = 8;
    final particleRadius = min(size.width, size.height) * 0.15 * progress;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + time * 2;
      final radius = particleRadius * (0.5 + 0.5 * sin(time + i));
      
      final position = center + Offset(
        cos(angle) * radius,
        sin(angle) * radius,
      );
      
      final opacity = 0.6 * progress * (1.0 + sin(time * 3 + i) * 0.5);
      
      // Create particle glow
      final glowPaint = Paint()
        ..color = spiralColor.withOpacity(opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(position, 8.0, glowPaint);
      
      // Create particle core
      final corePaint = Paint()
        ..color = spiralColor.withOpacity(opacity);
      
      canvas.drawCircle(position, 4.0, corePaint);
    }
  }

  /// Paints the progress indicator.
  void _paintProgressIndicator(Canvas canvas, Size size, Offset center) {
    final percentage = (progress * 100).round();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percentage%',
        style: TextStyle(
          color: spiralColor,
          fontSize: size.height * 0.15,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant SpiralGalaxyEffect oldDelegate) {
    return progress != oldDelegate.progress ||
           spiralColor != oldDelegate.spiralColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 