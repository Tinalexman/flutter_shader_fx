import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A glass morph effect painter that creates iOS-style frosted glass with blur.
/// 
/// This effect creates a frosted glass appearance with blur, transparency,
/// and subtle highlights. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: GlassMorphEffect(
///     blurRadius: 10.0,
///     transparency: 0.3,
///     borderColor: Colors.white,
///   ),
/// )
/// ```
class GlassMorphEffect extends BaseShaderPainter {
  /// Creates a glass morph effect painter.
  /// 
  /// [blurRadius] controls the blur intensity (0.0 to 20.0).
  /// [transparency] controls the glass transparency (0.0 to 1.0).
  /// [borderColor] is the color of the glass border.
  /// [borderWidth] is the width of the glass border.
  /// [performanceLevel] determines the quality settings.
  GlassMorphEffect({
    this.blurRadius = 10.0,
    this.transparency = 0.3,
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'glass_morph.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Blur intensity (0.0 to 20.0).
  final double blurRadius;

  /// Glass transparency (0.0 to 1.0).
  final double transparency;

  /// Color of the glass border.
  final Color borderColor;

  /// Width of the glass border.
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGlassMorph(canvas, size);
  }

  /// Paints the glass morph effect.
  void _paintGlassMorph(Canvas canvas, Size size) {
    // Paint glass background
    _paintGlassBackground(canvas, size);
    
    // Paint glass highlights
    _paintGlassHighlights(canvas, size);
    
    // Paint glass border
    _paintGlassBorder(canvas, size);
    
    // Paint glass reflections
    _paintGlassReflections(canvas, size);
  }

  /// Paints the glass background.
  void _paintGlassBackground(Canvas canvas, Size size) {
    final glassRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(size.height * 0.1);
    
    // Create glass gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.1 * (1.0 - transparency)),
        Colors.white.withOpacity(0.05 * (1.0 - transparency)),
        Colors.white.withOpacity(0.1 * (1.0 - transparency)),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(glassRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
    
    // Draw glass with rounded corners
    final path = Path();
    path.addRRect(borderRadius.toRRect(glassRect));
    canvas.drawPath(path, paint);
  }

  /// Paints glass highlights.
  void _paintGlassHighlights(Canvas canvas, Size size) {
    final highlightRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.3);
    final borderRadius = BorderRadius.circular(size.height * 0.1);
    
    // Create highlight gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.3 * (1.0 - transparency)),
        Colors.white.withOpacity(0.1 * (1.0 - transparency)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(highlightRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * 0.5);
    
    // Draw highlight with rounded corners
    final path = Path();
    path.addRRect(borderRadius.toRRect(highlightRect));
    canvas.drawPath(path, paint);
  }

  /// Paints the glass border.
  void _paintGlassBorder(Canvas canvas, Size size) {
    final borderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(size.height * 0.1);
    
    // Create border paint
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.3 * (1.0 - transparency))
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1);
    
    // Draw border with rounded corners
    final path = Path();
    path.addRRect(borderRadius.toRRect(borderRect));
    canvas.drawPath(path, borderPaint);
  }

  /// Paints glass reflections.
  void _paintGlassReflections(Canvas canvas, Size size) {
    final reflectionCount = 3;
    
    for (int i = 0; i < reflectionCount; i++) {
      final reflectionRect = Rect.fromLTWH(
        size.width * 0.1 + i * size.width * 0.2,
        size.height * 0.1 + i * size.height * 0.1,
        size.width * 0.1,
        size.height * 0.05,
      );
      
      // Create reflection gradient
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2 * (1.0 - transparency)),
          Colors.white.withOpacity(0.1 * (1.0 - transparency)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(reflectionRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * 0.3);
      
      // Draw reflection with rounded corners
      final borderRadius = BorderRadius.circular(reflectionRect.height * 0.5);
      final path = Path();
      path.addRRect(borderRadius.toRRect(reflectionRect));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GlassMorphEffect oldDelegate) {
    return blurRadius != oldDelegate.blurRadius ||
           transparency != oldDelegate.transparency ||
           borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 