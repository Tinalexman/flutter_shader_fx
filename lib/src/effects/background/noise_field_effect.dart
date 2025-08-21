import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A noise field effect painter that creates Perlin noise patterns.
/// 
/// This effect generates organic, flowing noise patterns using mathematical
/// functions to create smooth, animated noise fields. Currently uses a
/// gradient fallback since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: NoiseFieldEffect(
///     scale: 50.0,
///     speed: 1.0,
///     intensity: 0.8,
///   ),
/// )
/// ```
class NoiseFieldEffect extends BaseShaderPainter {
  /// Creates a noise field effect painter.
  /// 
  /// [scale] controls the scale of the noise pattern (higher = smaller details).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  NoiseFieldEffect({
    this.scale = 50.0,
    this.speed = 1.0,
    this.intensity = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'noise_field.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Scale of the noise pattern (higher = smaller details).
  final double scale;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a noise field fallback
    _paintNoiseField(canvas, size);
  }

  /// Paints a noise field effect using mathematical noise functions.
  void _paintNoiseField(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Create a noise field using multiple layers
    final noiseLayers = 3;
    final paint = Paint();
    
    for (int y = 0; y < size.height; y += 2) {
      for (int x = 0; x < size.width; x += 2) {
        final normalizedX = x / size.width;
        final normalizedY = y / size.height;
        
        // Generate noise value
        double noiseValue = 0.0;
        double amplitude = 1.0;
        double frequency = 1.0;
        
        for (int layer = 0; layer < noiseLayers; layer++) {
          final layerX = (normalizedX * scale * frequency + time * 0.5) % 1.0;
          final layerY = (normalizedY * scale * frequency + time * 0.3) % 1.0;
          
          noiseValue += amplitude * _perlinNoise(layerX, layerY);
          amplitude *= 0.5;
          frequency *= 2.0;
        }
        
        // Normalize noise value
        noiseValue = (noiseValue / noiseLayers).clamp(0.0, 1.0);
        
        // Apply intensity
        noiseValue *= intensity;
        
        // Create color based on noise value
        final color = _noiseToColor(noiseValue);
        
        // Draw pixel
        paint.color = color;
        canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 1.0, paint);
      }
    }
  }

  /// Simple Perlin noise implementation.
  double _perlinNoise(double x, double y) {
    // Simplified noise function for demonstration
    final noise1 = _hash(x * 12.9898 + y * 78.233);
    final noise2 = _hash(x * 37.719 + y * 49.123);
    final noise3 = _hash(x * 23.456 + y * 67.890);
    
    return (noise1 + noise2 + noise3) / 3.0;
  }

  /// Hash function for noise generation.
  double _hash(double n) {
    return (sin(n) * 43758.5453).abs() % 1.0;
  }

  /// Converts noise value to color.
  Color _noiseToColor(double noiseValue) {
    // Create a gradient from dark to light based on noise
    final darkColor = const Color(0xFF1a1a2e);
    final lightColor = const Color(0xFF16213e);
    final accentColor = const Color(0xFF0f3460);
    
    if (noiseValue < 0.33) {
      return Color.lerp(darkColor, accentColor, noiseValue * 3.0)!;
    } else if (noiseValue < 0.66) {
      return Color.lerp(accentColor, lightColor, (noiseValue - 0.33) * 3.0)!;
    } else {
      return Color.lerp(lightColor, Colors.white, (noiseValue - 0.66) * 3.0)!;
    }
  }

  @override
  bool shouldRepaint(covariant NoiseFieldEffect oldDelegate) {
    return scale != oldDelegate.scale ||
           speed != oldDelegate.speed ||
           intensity != oldDelegate.intensity ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 