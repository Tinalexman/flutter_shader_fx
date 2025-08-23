import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A liquid progress effect painter that creates fluid filling animation.
/// 
/// This effect creates a liquid-like progress bar with fluid animations
/// and realistic liquid physics. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: LiquidProgressEffect(
///     progress: 0.7,
///     liquidColor: Colors.blue,
///     speed: 1.0,
///   ),
/// )
/// ```
class LiquidProgressEffect extends BaseShaderPainter {
  /// Creates a liquid progress effect painter.
  /// 
  /// [progress] is the progress value (0.0 to 1.0).
  /// [liquidColor] is the color of the liquid.
  /// [speed] controls the liquid animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  LiquidProgressEffect({
    this.progress = 0.0,
    this.liquidColor = Colors.blue,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'liquid_progress.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Progress value (0.0 to 1.0).
  final double progress;

  /// Color of the liquid.
  final Color liquidColor;

  /// Liquid animation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLiquidProgress(canvas, size);
  }

  /// Paints the liquid progress effect.
  void _paintLiquidProgress(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Paint container background
    _paintContainer(canvas, size);
    
    // Paint liquid
    _paintLiquid(canvas, size, time);
    
    // Paint liquid surface
    _paintLiquidSurface(canvas, size, time);
    
    // Paint bubbles
    _paintBubbles(canvas, size, time);
    
    // Paint progress indicator
    _paintProgressIndicator(canvas, size);
  }

  /// Paints the container background.
  void _paintContainer(Canvas canvas, Size size) {
    final containerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(size.height / 2);
    
    // Create container gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey.withOpacity(0.3),
        Colors.grey.withOpacity(0.1),
        Colors.grey.withOpacity(0.3),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(containerRect);
    
    // Draw container with rounded corners
    final path = Path();
    path.addRRect(borderRadius.toRRect(containerRect));
    canvas.drawPath(path, paint);
    
    // Draw container border
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawPath(path, borderPaint);
  }

  /// Paints the liquid.
  void _paintLiquid(Canvas canvas, Size size, double time) {
    final liquidHeight = size.height * progress;
    final liquidRect = Rect.fromLTWH(0, size.height - liquidHeight, size.width, liquidHeight);
    
    // Create liquid gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        liquidColor.withOpacity(0.8),
        liquidColor.withOpacity(0.6),
        liquidColor.withOpacity(0.4),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(liquidRect);
    
    // Draw liquid with wave effect
    final path = Path();
    path.moveTo(0, size.height);
    
    // Create wave effect at liquid surface
    for (int x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final waveOffset = sin(normalizedX * 4 * pi + time * 2) * 5.0;
      final y = size.height - liquidHeight + waveOffset;
      path.lineTo(x.toDouble(), y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  /// Paints the liquid surface.
  void _paintLiquidSurface(Canvas canvas, Size size, double time) {
    final liquidHeight = size.height * progress;
    
    // Create surface highlight
    final surfacePath = Path();
    surfacePath.moveTo(0, size.height - liquidHeight);
    
    for (int x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final waveOffset = sin(normalizedX * 4 * pi + time * 2) * 5.0;
      final y = size.height - liquidHeight + waveOffset;
      surfacePath.lineTo(x.toDouble(), y);
    }
    
    final surfacePaint = Paint()
      ..color = liquidColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawPath(surfacePath, surfacePaint);
  }

  /// Paints bubbles in the liquid.
  void _paintBubbles(Canvas canvas, Size size, double time) {
    final bubbleCount = 8;
    final liquidHeight = size.height * progress;
    
    for (int i = 0; i < bubbleCount; i++) {
      final bubbleX = (i / bubbleCount) * size.width + sin(time + i) * 10.0;
      final bubbleY = size.height - (liquidHeight * 0.3) + sin(time * 0.5 + i) * 5.0;
      final bubbleSize = 3.0 + sin(time + i * 2) * 2.0;
      
      if (bubbleY < size.height - liquidHeight) continue;
      
      // Create bubble glow
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize * 2, glowPaint);
      
      // Create bubble core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(0.8);
      
      canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize, corePaint);
    }
  }

  /// Paints the progress indicator.
  void _paintProgressIndicator(Canvas canvas, Size size) {
    final liquidHeight = size.height * progress;
    final indicatorY = size.height - liquidHeight;
    
    // Create progress line
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawLine(
      Offset(0, indicatorY),
      Offset(size.width, indicatorY),
      linePaint,
    );
    
    // Create progress percentage
    final percentage = (progress * 100).round();
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percentage%',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant LiquidProgressEffect oldDelegate) {
    return progress != oldDelegate.progress ||
           liquidColor != oldDelegate.liquidColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 