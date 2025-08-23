import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A geometric morph effect painter that creates shape transformation for progress.
/// 
/// This effect creates geometric shapes that morph and transform to indicate
/// progress with smooth animations. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: GeometricMorphEffect(
///     progress: 0.7,
///     morphColor: Colors.purple,
///     speed: 1.0,
///   ),
/// )
/// ```
class GeometricMorphEffect extends BaseShaderPainter {
  /// Creates a geometric morph effect painter.
  /// 
  /// [progress] is the progress value (0.0 to 1.0).
  /// [morphColor] is the color of the morphing shapes.
  /// [speed] controls the morphing animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  GeometricMorphEffect({
    this.progress = 0.0,
    this.morphColor = Colors.purple,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'geometric_morph.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Progress value (0.0 to 1.0).
  final double progress;

  /// Color of the morphing shapes.
  final Color morphColor;

  /// Morphing animation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGeometricMorph(canvas, size);
  }

  /// Paints the geometric morph effect.
  void _paintGeometricMorph(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    final center = Offset(size.width / 2, size.height / 2);
    
    // Paint background
    _paintBackground(canvas, size);
    
    // Paint morphing shapes
    _paintMorphingShapes(canvas, size, center, time);
    
    // Paint progress indicator
    _paintProgressIndicator(canvas, size, center);
    
    // Paint connecting lines
    _paintConnectingLines(canvas, size, center, time);
  }

  /// Paints the background.
  void _paintBackground(Canvas canvas, Size size) {
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create background gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.black.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(backgroundRect);
    
    canvas.drawRect(backgroundRect, paint);
  }

  /// Paints morphing shapes.
  void _paintMorphingShapes(Canvas canvas, Size size, Offset center, double time) {
    final shapeCount = 5;
    final baseRadius = min(size.width, size.height) * 0.15;
    
    for (int i = 0; i < shapeCount; i++) {
      final angle = (i / shapeCount) * 2 * pi + time * 0.5;
      final distance = baseRadius * (1.0 + sin(time + i) * 0.3);
      final shapeRadius = baseRadius * 0.3 * (1.0 + progress * 0.5);
      
      final position = center + Offset(
        cos(angle) * distance,
        sin(angle) * distance,
      );
      
      // Determine shape type based on progress
      final shapeType = (progress * shapeCount + i).floor() % 4;
      
      switch (shapeType) {
        case 0:
          _paintCircle(canvas, position, shapeRadius, i, time);
          break;
        case 1:
          _paintSquare(canvas, position, shapeRadius, i, time);
          break;
        case 2:
          _paintTriangle(canvas, position, shapeRadius, i, time);
          break;
        case 3:
          _paintDiamond(canvas, position, shapeRadius, i, time);
          break;
      }
    }
  }

  /// Paints a circle shape.
  void _paintCircle(Canvas canvas, Offset center, double radius, int index, double time) {
    final opacity = 0.6 + 0.4 * sin(time * 2 + index);
    
    // Create circle glow
    final glowPaint = Paint()
      ..color = morphColor.withOpacity(opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(center, radius * 1.5, glowPaint);
    
    // Create circle core
    final corePaint = Paint()
      ..color = morphColor.withOpacity(opacity);
    
    canvas.drawCircle(center, radius, corePaint);
  }

  /// Paints a square shape.
  void _paintSquare(Canvas canvas, Offset center, double radius, int index, double time) {
    final opacity = 0.6 + 0.4 * sin(time * 2 + index);
    final rect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 2);
    
    // Create square glow
    final glowPaint = Paint()
      ..color = morphColor.withOpacity(opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawRect(rect.inflate(radius * 0.5), glowPaint);
    
    // Create square core
    final corePaint = Paint()
      ..color = morphColor.withOpacity(opacity);
    
    canvas.drawRect(rect, corePaint);
  }

  /// Paints a triangle shape.
  void _paintTriangle(Canvas canvas, Offset center, double radius, int index, double time) {
    final opacity = 0.6 + 0.4 * sin(time * 2 + index);
    
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.866, center.dy + radius * 0.5);
    path.lineTo(center.dx + radius * 0.866, center.dy + radius * 0.5);
    path.close();
    
    // Create triangle glow
    final glowPaint = Paint()
      ..color = morphColor.withOpacity(opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    final glowPath = Path();
    glowPath.moveTo(center.dx, center.dy - radius * 1.5);
    glowPath.lineTo(center.dx - radius * 1.3, center.dy + radius * 0.75);
    glowPath.lineTo(center.dx + radius * 1.3, center.dy + radius * 0.75);
    glowPath.close();
    
    canvas.drawPath(glowPath, glowPaint);
    
    // Create triangle core
    final corePaint = Paint()
      ..color = morphColor.withOpacity(opacity);
    
    canvas.drawPath(path, corePaint);
  }

  /// Paints a diamond shape.
  void _paintDiamond(Canvas canvas, Offset center, double radius, int index, double time) {
    final opacity = 0.6 + 0.4 * sin(time * 2 + index);
    
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius, center.dy);
    path.close();
    
    // Create diamond glow
    final glowPaint = Paint()
      ..color = morphColor.withOpacity(opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    final glowPath = Path();
    glowPath.moveTo(center.dx, center.dy - radius * 1.5);
    glowPath.lineTo(center.dx + radius * 1.5, center.dy);
    glowPath.lineTo(center.dx, center.dy + radius * 1.5);
    glowPath.lineTo(center.dx - radius * 1.5, center.dy);
    glowPath.close();
    
    canvas.drawPath(glowPath, glowPaint);
    
    // Create diamond core
    final corePaint = Paint()
      ..color = morphColor.withOpacity(opacity);
    
    canvas.drawPath(path, corePaint);
  }

  /// Paints the progress indicator.
  void _paintProgressIndicator(Canvas canvas, Size size, Offset center) {
    final percentage = (progress * 100).round();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percentage%',
        style: TextStyle(
          color: morphColor,
          fontSize: size.height * 0.2,
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

  /// Paints connecting lines between shapes.
  void _paintConnectingLines(Canvas canvas, Size size, Offset center, double time) {
    final shapeCount = 5;
    final baseRadius = min(size.width, size.height) * 0.15;
    
    for (int i = 0; i < shapeCount; i++) {
      final angle1 = (i / shapeCount) * 2 * pi + time * 0.5;
      final angle2 = ((i + 1) / shapeCount) * 2 * pi + time * 0.5;
      
      final distance1 = baseRadius * (1.0 + sin(time + i) * 0.3);
      final distance2 = baseRadius * (1.0 + sin(time + i + 1) * 0.3);
      
      final point1 = center + Offset(
        cos(angle1) * distance1,
        sin(angle1) * distance1,
      );
      
      final point2 = center + Offset(
        cos(angle2) * distance2,
        sin(angle2) * distance2,
      );
      
      final opacity = 0.3 * (1.0 + sin(time + i) * 0.5);
      
      final paint = Paint()
        ..color = morphColor.withOpacity(opacity)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      
      canvas.drawLine(point1, point2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GeometricMorphEffect oldDelegate) {
    return progress != oldDelegate.progress ||
           morphColor != oldDelegate.morphColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 