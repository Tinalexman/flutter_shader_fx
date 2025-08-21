import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A fractal effect painter that creates Mandelbrot/Julia set variations.
/// 
/// This effect generates beautiful fractal patterns with zoom capability
/// and smooth color transitions. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: FractalEffect(
///     zoom: 1.0,
///     center: Offset(0.5, 0.5),
///     maxIterations: 100,
///   ),
/// )
/// ```
class FractalEffect extends BaseShaderPainter {
  /// Creates a fractal effect painter.
  /// 
  /// [zoom] controls the zoom level (higher = more zoomed in).
  /// [center] is the center point of the fractal (normalized coordinates).
  /// [maxIterations] is the maximum number of iterations for fractal calculation.
  /// [performanceLevel] determines the quality settings.
  FractalEffect({
    this.zoom = 1.0,
    this.center = const Offset(0.5, 0.5),
    this.maxIterations = 100,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'fractal.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Zoom level (higher = more zoomed in).
  final double zoom;

  /// Center point of the fractal (normalized coordinates).
  final Offset center;

  /// Maximum number of iterations for fractal calculation.
  final int maxIterations;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a fractal fallback
    _paintFractal(canvas, size);
  }

  /// Paints a fractal pattern using Mandelbrot set calculations.
  void _paintFractal(Canvas canvas, Size size) {
    // Adjust iterations based on performance level
    final adjustedIterations = _getAdjustedIterations();
    
    // Calculate fractal bounds
    final bounds = _calculateFractalBounds(size);
    
    // Create color palette
    final colors = _createColorPalette();
    
    // Draw fractal
    for (int y = 0; y < size.height; y += 2) {
      for (int x = 0; x < size.width; x += 2) {
        final normalizedX = x / size.width;
        final normalizedY = y / size.height;
        
        // Transform coordinates to fractal space
        final fractalX = bounds.left + (bounds.right - bounds.left) * normalizedX;
        final fractalY = bounds.top + (bounds.bottom - bounds.top) * normalizedY;
        
        // Calculate fractal value
        final value = _calculateMandelbrot(fractalX, fractalY, adjustedIterations);
        
        // Convert to color
        final color = _valueToColor(value, adjustedIterations, colors);
        
        // Draw pixel
        final paint = Paint()..color = color;
        canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1.0, paint);
      }
    }
  }

  /// Gets adjusted iteration count based on performance level.
  int _getAdjustedIterations() {
    switch (performanceLevel) {
      case PerformanceLevel.low:
        return (maxIterations * 0.3).round();
      case PerformanceLevel.medium:
        return (maxIterations * 0.6).round();
      case PerformanceLevel.high:
        return maxIterations;
    }
  }

  /// Calculates fractal bounds based on zoom and center.
  Rect _calculateFractalBounds(Size size) {
    // Standard Mandelbrot bounds
    const baseLeft = -2.0;
    const baseRight = 1.0;
    const baseTop = -1.5;
    const baseBottom = 1.5;
    
    // Apply zoom
    final zoomFactor = 1.0 / zoom;
    final width = (baseRight - baseLeft) * zoomFactor;
    final height = (baseBottom - baseTop) * zoomFactor;
    
    // Apply center offset
    final centerX = baseLeft + (baseRight - baseLeft) * center.dx;
    final centerY = baseTop + (baseBottom - baseTop) * center.dy;
    
    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: width,
      height: height,
    );
  }

  /// Calculates Mandelbrot set value for given coordinates.
  double _calculateMandelbrot(double x, double y, int maxIter) {
    double zx = 0.0;
    double zy = 0.0;
    
    for (int i = 0; i < maxIter; i++) {
      final zx2 = zx * zx;
      final zy2 = zy * zy;
      
      if (zx2 + zy2 > 4.0) {
        // Escape condition met
        return i.toDouble() + 1.0 - log(log(sqrt(zx2 + zy2))) / log(2.0);
      }
      
      final temp = zx2 - zy2 + x;
      zy = 2.0 * zx * zy + y;
      zx = temp;
    }
    
    // Point is in the set
    return maxIter.toDouble();
  }

  /// Creates a color palette for the fractal.
  List<Color> _createColorPalette() {
    return [
      const Color(0xFF000000), // Black
      const Color(0xFF000033), // Dark blue
      const Color(0xFF000066), // Blue
      const Color(0xFF000099), // Light blue
      const Color(0xFF0000CC), // Cyan
      const Color(0xFF00FFFF), // Bright cyan
      const Color(0xFF00FFCC), // Green cyan
      const Color(0xFF00FF99), // Green
      const Color(0xFF00FF66), // Light green
      const Color(0xFF00FF33), // Bright green
      const Color(0xFF00FF00), // Lime
      const Color(0xFF33FF00), // Yellow green
      const Color(0xFF66FF00), // Yellow
      const Color(0xFF99FF00), // Orange yellow
      const Color(0xFFCCFF00), // Orange
      const Color(0xFFFF0000), // Red
      const Color(0xFFFF0033), // Pink
      const Color(0xFFFF0066), // Magenta
      const Color(0xFFFF0099), // Purple
      const Color(0xFFFF00CC), // Violet
      const Color(0xFFFF00FF), // Bright magenta
      const Color(0xFFFFFFFF), // White
    ];
  }

  /// Converts fractal value to color.
  Color _valueToColor(double value, int maxIter, List<Color> colors) {
    if (value >= maxIter) {
      return Colors.black; // Point is in the set
    }
    
    // Normalize value to color index
    final normalizedValue = value / maxIter;
    final colorIndex = (normalizedValue * (colors.length - 1)).clamp(0.0, colors.length - 1.0);
    
    final index1 = colorIndex.floor();
    final index2 = (index1 + 1).clamp(0, colors.length - 1);
    final t = colorIndex - index1;
    
    return Color.lerp(colors[index1], colors[index2], t)!;
  }

  @override
  bool shouldRepaint(covariant FractalEffect oldDelegate) {
    return zoom != oldDelegate.zoom ||
           center != oldDelegate.center ||
           maxIterations != oldDelegate.maxIterations ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 