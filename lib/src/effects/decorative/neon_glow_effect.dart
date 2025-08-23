import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A neon glow effect painter that creates cyberpunk neon borders and highlights.
/// 
/// This effect creates vibrant neon glows with cyberpunk aesthetics,
/// including animated borders and highlights. Currently uses a simplified
/// implementation since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: NeonGlowEffect(
///     neonColor: Colors.cyan,
///     glowIntensity: 0.8,
///     pulseSpeed: 1.0,
///   ),
/// )
/// ```
class NeonGlowEffect extends BaseShaderPainter {
  /// Creates a neon glow effect painter.
  /// 
  /// [neonColor] is the color of the neon glow.
  /// [glowIntensity] controls the glow intensity (0.0 to 1.0).
  /// [pulseSpeed] controls the pulse animation speed (0.5 to 2.0).
  /// [borderWidth] is the width of the neon border.
  /// [performanceLevel] determines the quality settings.
  NeonGlowEffect({
    this.neonColor = Colors.cyan,
    this.glowIntensity = 0.8,
    this.pulseSpeed = 1.0,
    this.borderWidth = 3.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'neon_glow.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Color of the neon glow.
  final Color neonColor;

  /// Glow intensity (0.0 to 1.0).
  final double glowIntensity;

  /// Pulse animation speed (0.5 to 2.0).
  final double pulseSpeed;

  /// Width of the neon border.
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    _paintNeonGlow(canvas, size);
  }

  /// Paints the neon glow effect.
  void _paintNeonGlow(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * pulseSpeed;
    
    // Paint neon border
    _paintNeonBorder(canvas, size, time);
    
    // Paint neon highlights
    _paintNeonHighlights(canvas, size, time);
    
    // Paint neon particles
    _paintNeonParticles(canvas, size, time);
    
    // Paint neon glow
    _paintNeonGlowLayers(canvas, size, time);
  }

  /// Paints the neon border.
  void _paintNeonBorder(Canvas canvas, Size size, double time) {
    final borderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(size.height * 0.1);
    
    // Create pulsing effect
    final pulseValue = (sin(time * 2) + 1.0) / 2.0;
    final currentIntensity = glowIntensity * (0.7 + 0.3 * pulseValue);
    
    // Create neon border gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        neonColor.withOpacity(currentIntensity),
        neonColor.withOpacity(currentIntensity * 0.8),
        neonColor.withOpacity(currentIntensity),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(borderRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
    
    // Draw border with rounded corners
    final path = Path();
    path.addRRect(borderRadius.toRRect(borderRect));
    canvas.drawPath(path, paint);
    
    // Draw inner border
    final innerPaint = Paint()
      ..color = neonColor.withOpacity(currentIntensity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawPath(path, innerPaint);
  }

  /// Paints neon highlights.
  void _paintNeonHighlights(Canvas canvas, Size size, double time) {
    final highlightCount = 4;
    
    for (int i = 0; i < highlightCount; i++) {
      final angle = (i / highlightCount) * 2 * pi + time * 0.5;
      final highlightPos = Offset(
        size.width * 0.5 + cos(angle) * size.width * 0.3,
        size.height * 0.5 + sin(angle) * size.height * 0.3,
      );
      
      final pulseValue = (sin(time * 3 + i) + 1.0) / 2.0;
      final highlightOpacity = glowIntensity * pulseValue;
      
      // Create highlight glow
      final glowPaint = Paint()
        ..color = neonColor.withOpacity(highlightOpacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(highlightPos, 15.0, glowPaint);
      
      // Create highlight core
      final corePaint = Paint()
        ..color = neonColor.withOpacity(highlightOpacity);
      
      canvas.drawCircle(highlightPos, 5.0, corePaint);
    }
  }

  /// Paints neon particles.
  void _paintNeonParticles(Canvas canvas, Size size, double time) {
    final particleCount = 8;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + time * 0.3;
      final radius = size.width * 0.4 + sin(time + i) * 10.0;
      
      final particlePos = Offset(
        size.width * 0.5 + cos(angle) * radius,
        size.height * 0.5 + sin(angle) * radius,
      );
      
      final particleOpacity = glowIntensity * (0.5 + 0.5 * sin(time * 2 + i));
      
      if (particleOpacity > 0.1) {
        // Create particle glow
        final glowPaint = Paint()
          ..color = neonColor.withOpacity(particleOpacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        
        canvas.drawCircle(particlePos, 8.0, glowPaint);
        
        // Create particle core
        final corePaint = Paint()
          ..color = neonColor.withOpacity(particleOpacity);
        
        canvas.drawCircle(particlePos, 3.0, corePaint);
      }
    }
  }

  /// Paints neon glow layers.
  void _paintNeonGlowLayers(Canvas canvas, Size size, double time) {
    final glowRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(size.height * 0.1);
    
    // Create multiple glow layers
    final layerCount = 3;
    
    for (int layer = 0; layer < layerCount; layer++) {
      final layerOpacity = glowIntensity * (1.0 - layer / layerCount) * 0.2;
      final layerBlur = (layer + 1) * 3.0;
      
      // Create glow gradient
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          neonColor.withOpacity(layerOpacity),
          neonColor.withOpacity(layerOpacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(glowRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerBlur);
      
      // Draw glow with rounded corners
      final path = Path();
      path.addRRect(borderRadius.toRRect(glowRect));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NeonGlowEffect oldDelegate) {
    return neonColor != oldDelegate.neonColor ||
           glowIntensity != oldDelegate.glowIntensity ||
           pulseSpeed != oldDelegate.pulseSpeed ||
           borderWidth != oldDelegate.borderWidth ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 