import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// An aurora effect painter that creates northern lights with realistic colors.
/// 
/// This effect generates beautiful aurora borealis patterns with flowing
/// green, blue, and purple colors. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: AuroraEffect(
///     intensity: 0.8,
///     speed: 1.0,
///     layers: 3,
///   ),
/// )
/// ```
class AuroraEffect extends BaseShaderPainter {
  /// Creates an aurora effect painter.
  /// 
  /// [intensity] controls the aurora intensity (0.0 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [layers] is the number of aurora layers (1 to 5).
  /// [performanceLevel] determines the quality settings.
  AuroraEffect({
    this.intensity = 0.8,
    this.speed = 1.0,
    this.layers = 3,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'aurora.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Aurora intensity (0.0 to 1.0).
  final double intensity;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Number of aurora layers (1 to 5).
  final int layers;

  @override
  void paint(Canvas canvas, Size size) {
    _paintAurora(canvas, size);
  }

  /// Paints aurora borealis effect.
  void _paintAurora(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Paint night sky background
    _paintNightSky(canvas, size);
    
    // Paint aurora layers
    for (int i = 0; i < layers; i++) {
      _paintAuroraLayer(canvas, size, time, i);
    }
  }

  /// Paints the night sky background.
  void _paintNightSky(Canvas canvas, Size size) {
    // Create night sky gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF000033), // Dark blue
        const Color(0xFF001122), // Darker blue
        const Color(0xFF000011), // Almost black
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final skyPaint = Paint()
      ..shader = skyGradient.createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, skyPaint);
  }

  /// Paints a single aurora layer.
  void _paintAuroraLayer(Canvas canvas, Size size, double time, int layerIndex) {
    final layerHeight = size.height * 0.3;
    final layerY = size.height * 0.2 + layerIndex * layerHeight * 0.3;
    
    // Create aurora path
    final path = Path();
    path.moveTo(0, layerY);
    
    // Generate flowing aurora curve
    for (int x = 0; x <= size.width; x += 5) {
      final normalizedX = x / size.width;
      final wave1 = sin(normalizedX * 4 * pi + time * 0.5 + layerIndex) * 30;
      final wave2 = sin(normalizedX * 2 * pi + time * 0.3 + layerIndex * 2) * 20;
      final wave3 = sin(normalizedX * 6 * pi + time * 0.7 + layerIndex * 3) * 15;
      
      final y = layerY + wave1 + wave2 + wave3;
      path.lineTo(x.toDouble(), y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    // Create aurora gradient
    final auroraColors = _getAuroraColors(layerIndex);
    final auroraGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: auroraColors,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    final auroraPaint = Paint()
      ..shader = auroraGradient.createShader(Offset.zero & size)
      ..color = Colors.white.withOpacity(intensity * (1.0 - layerIndex * 0.2));
    
    canvas.drawPath(path, auroraPaint);
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = auroraColors[1].withOpacity(intensity * 0.3 * (1.0 - layerIndex * 0.2))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(path, glowPaint);
  }

  /// Gets aurora colors for a specific layer.
  List<Color> _getAuroraColors(int layerIndex) {
    switch (layerIndex % 3) {
      case 0:
        return [
          Colors.transparent,
          const Color(0xFF00FF80).withOpacity(0.8), // Green
          const Color(0xFF00FF40).withOpacity(0.6), // Bright green
          Colors.transparent,
        ];
      case 1:
        return [
          Colors.transparent,
          const Color(0xFF00FFFF).withOpacity(0.8), // Cyan
          const Color(0xFF0080FF).withOpacity(0.6), // Blue
          Colors.transparent,
        ];
      case 2:
        return [
          Colors.transparent,
          const Color(0xFF8000FF).withOpacity(0.8), // Purple
          const Color(0xFF4000FF).withOpacity(0.6), // Blue purple
          Colors.transparent,
        ];
      default:
        return [
          Colors.transparent,
          const Color(0xFF00FF80).withOpacity(0.8),
          const Color(0xFF00FF40).withOpacity(0.6),
          Colors.transparent,
        ];
    }
  }

  @override
  bool shouldRepaint(covariant AuroraEffect oldDelegate) {
    return intensity != oldDelegate.intensity ||
           speed != oldDelegate.speed ||
           layers != oldDelegate.layers ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 