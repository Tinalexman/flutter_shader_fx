import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A wave effect painter that creates sine wave interference patterns.
/// 
/// This effect generates beautiful wave interference patterns with
/// customizable frequency and amplitude. Currently uses a simplified
/// implementation since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: WaveEffect(
///     frequency: 2.0,
///     amplitude: 0.5,
///     speed: 1.0,
///   ),
/// )
/// ```
class WaveEffect extends BaseShaderPainter {
  /// Creates a wave effect painter.
  /// 
  /// [frequency] controls the wave frequency (0.5 to 5.0).
  /// [amplitude] controls the wave amplitude (0.1 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [performanceLevel] determines the quality settings.
  WaveEffect({
    this.frequency = 2.0,
    this.amplitude = 0.5,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'wave.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Wave frequency (0.5 to 5.0).
  final double frequency;

  /// Wave amplitude (0.1 to 1.0).
  final double amplitude;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintWavePattern(canvas, size);
  }

  /// Paints wave interference patterns.
  void _paintWavePattern(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Create wave pattern
    for (int y = 0; y < size.height; y += 2) {
      for (int x = 0; x < size.width; x += 2) {
        final normalizedX = x / size.width;
        final normalizedY = y / size.height;
        
        // Calculate wave values
        final wave1 = _calculateWave(normalizedX, normalizedY, time, 1.0);
        final wave2 = _calculateWave(normalizedX, normalizedY, time, 1.5);
        final wave3 = _calculateWave(normalizedX, normalizedY, time, 2.0);
        
        // Combine waves
        final combinedWave = (wave1 + wave2 + wave3) / 3.0;
        
        // Convert to color
        final color = _waveToColor(combinedWave);
        
        // Draw pixel
        final paint = Paint()..color = color;
        canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1.0, paint);
      }
    }
  }

  /// Calculates wave value at given position and time.
  double _calculateWave(double x, double y, double time, double waveNumber) {
    // Create interference pattern
    final wave1 = sin(x * frequency * waveNumber + time);
    final wave2 = sin(y * frequency * waveNumber + time * 0.7);
    final wave3 = sin((x + y) * frequency * waveNumber * 0.5 + time * 1.3);
    
    return (wave1 + wave2 + wave3) / 3.0 * amplitude;
  }

  /// Converts wave value to color.
  Color _waveToColor(double waveValue) {
    // Normalize wave value to 0-1 range
    final normalized = (waveValue + 1.0) / 2.0;
    
    // Create color gradient
    if (normalized < 0.33) {
      return Color.lerp(
        const Color(0xFF000033), // Dark blue
        const Color(0xFF000066), // Blue
        normalized * 3.0,
      )!;
    } else if (normalized < 0.66) {
      return Color.lerp(
        const Color(0xFF000066), // Blue
        const Color(0xFF00FFFF), // Cyan
        (normalized - 0.33) * 3.0,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFF00FFFF), // Cyan
        const Color(0xFFFFFFFF), // White
        (normalized - 0.66) * 3.0,
      )!;
    }
  }

  @override
  bool shouldRepaint(covariant WaveEffect oldDelegate) {
    return frequency != oldDelegate.frequency ||
           amplitude != oldDelegate.amplitude ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 