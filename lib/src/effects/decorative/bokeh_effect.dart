import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A bokeh effect painter that creates depth of field blur with customizable focus.
/// 
/// This effect creates realistic depth of field blur with bokeh highlights
/// and customizable focus points. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: BokehEffect(
///     focusPoint: Offset(0.5, 0.5),
///     focusDepth: 0.5,
///     bokehIntensity: 0.8,
///   ),
/// )
/// ```
class BokehEffect extends BaseShaderPainter {
  /// Creates a bokeh effect painter.
  /// 
  /// [focusPoint] is the point of focus (normalized coordinates).
  /// [focusDepth] controls the depth of field (0.0 to 1.0).
  /// [bokehIntensity] controls the bokeh highlight intensity (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  BokehEffect({
    this.focusPoint = const Offset(0.5, 0.5),
    this.focusDepth = 0.5,
    this.bokehIntensity = 0.8,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'bokeh.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Point of focus (normalized coordinates).
  final Offset focusPoint;

  /// Depth of field (0.0 to 1.0).
  final double focusDepth;

  /// Bokeh highlight intensity (0.0 to 1.0).
  final double bokehIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBokehEffect(canvas, size);
  }

  /// Paints the bokeh effect.
  void _paintBokehEffect(Canvas canvas, Size size) {
    // Paint base background
    _paintBaseBackground(canvas, size);
    
    // Paint bokeh highlights
    _paintBokehHighlights(canvas, size);
    
    // Paint depth blur
    _paintDepthBlur(canvas, size);
    
    // Paint focus area
    _paintFocusArea(canvas, size);
  }

  /// Paints the base background.
  void _paintBaseBackground(Canvas canvas, Size size) {
    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create background gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black.withOpacity(0.1),
        Colors.grey.withOpacity(0.2),
        Colors.black.withOpacity(0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(backgroundRect);
    
    canvas.drawRect(backgroundRect, paint);
  }

  /// Paints bokeh highlights.
  void _paintBokehHighlights(Canvas canvas, Size size) {
    final highlightCount = 15;
    
    for (int i = 0; i < highlightCount; i++) {
      final highlightPos = Offset(
        (i * 0.7) % 1.0 * size.width,
        (i * 0.5) % 1.0 * size.height,
      );
      
      final distanceFromFocus = (highlightPos - Offset(
        focusPoint.dx * size.width,
        focusPoint.dy * size.height,
      )).distance;
      
      final maxDistance = min(size.width, size.height) * 0.5;
      final blurAmount = (distanceFromFocus / maxDistance) * focusDepth;
      
      final highlightSize = 10.0 + sin(i * 0.5) * 5.0;
      final highlightOpacity = bokehIntensity * (1.0 - blurAmount * 0.5);
      
      if (highlightOpacity > 0.1) {
        _paintBokehHighlight(canvas, highlightPos, highlightSize, blurAmount, highlightOpacity);
      }
    }
  }

  /// Paints a single bokeh highlight.
  void _paintBokehHighlight(Canvas canvas, Offset position, double size, double blurAmount, double opacity) {
    // Create bokeh shape (hexagon-like)
    final path = Path();
    final sides = 6;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i / sides) * 2 * pi;
      final radius = size * (1.0 + sin(angle * 3) * 0.2);
      final x = position.dx + cos(angle) * radius;
      final y = position.dy + sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    // Create bokeh gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.white.withOpacity(opacity * 0.8),
        Colors.white.withOpacity(opacity * 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: position,
          width: size * 2,
          height: size * 2,
        ),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurAmount * 3);
    
    canvas.drawPath(path, paint);
  }

  /// Paints depth blur.
  void _paintDepthBlur(Canvas canvas, Size size) {
    final focusPos = Offset(
      focusPoint.dx * size.width,
      focusPoint.dy * size.height,
    );
    
    // Create depth blur gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.1 * focusDepth),
        Colors.black.withOpacity(0.3 * focusDepth),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final maxRadius = min(size.width, size.height) * 0.8;
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: focusPos,
          width: maxRadius * 2,
          height: maxRadius * 2,
        ),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(focusPos, maxRadius, paint);
  }

  /// Paints the focus area.
  void _paintFocusArea(Canvas canvas, Size size) {
    final focusPos = Offset(
      focusPoint.dx * size.width,
      focusPoint.dy * size.height,
    );
    
    final focusRadius = min(size.width, size.height) * 0.1;
    
    // Create focus ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    
    canvas.drawCircle(focusPos, focusRadius, ringPaint);
    
    // Create focus center
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5);
    
    canvas.drawCircle(focusPos, 3.0, centerPaint);
  }

  @override
  bool shouldRepaint(covariant BokehEffect oldDelegate) {
    return focusPoint != oldDelegate.focusPoint ||
           focusDepth != oldDelegate.focusDepth ||
           bokehIntensity != oldDelegate.bokehIntensity ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 