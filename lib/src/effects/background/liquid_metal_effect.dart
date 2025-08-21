import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A liquid metal effect painter that creates reflective metallic surfaces.
/// 
/// This effect simulates liquid metal with reflective properties, lighting,
/// and flowing animations. Currently uses a gradient fallback since shader
/// compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: LiquidMetalEffect(
///     metallicness: 0.8,
///     roughness: 0.2,
///     speed: 1.0,
///   ),
/// )
/// ```
class LiquidMetalEffect extends BaseShaderPainter {
  /// Creates a liquid metal effect painter.
  /// 
  /// [metallicness] controls the metallic appearance (0.0 to 1.0).
  /// [roughness] controls the surface roughness (0.0 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [performanceLevel] determines the quality settings.
  LiquidMetalEffect({
    this.metallicness = 0.8,
    this.roughness = 0.2,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'liquid_metal.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Metallic appearance (0.0 to 1.0).
  final double metallicness;

  /// Surface roughness (0.0 to 1.0).
  final double roughness;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a liquid metal fallback
    _paintLiquidMetal(canvas, size);
  }

  /// Paints a liquid metal effect with reflective properties.
  void _paintLiquidMetal(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Create base metallic gradient
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.8;
    
    // Create metallic gradient
    final metallicGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        const Color(0xFF8B8B8B), // Steel gray
        const Color(0xFFC0C0C0), // Silver
        const Color(0xFFE5E5E5), // Light silver
        const Color(0xFFF5F5F5), // Almost white
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    // Draw base metallic surface
    final basePaint = Paint()
      ..shader = metallicGradient.createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, basePaint);
    
    // Add reflective highlights
    _paintReflections(canvas, size, time);
    
    // Add liquid flow patterns
    _paintLiquidFlow(canvas, size, time);
    
    // Add surface imperfections
    _paintSurfaceImperfections(canvas, size, roughness);
  }

  /// Paints reflective highlights on the metallic surface.
  void _paintReflections(Canvas canvas, Size size, double time) {
    final highlightCount = 3;
    
    for (int i = 0; i < highlightCount; i++) {
      final angle = (time * 0.5 + i * 2 * pi / highlightCount) % (2 * pi);
      final distance = size.width * 0.3;
      
      final x = size.width / 2 + cos(angle) * distance;
      final y = size.height / 2 + sin(angle) * distance;
      
      // Create highlight gradient
      final highlightGradient = RadialGradient(
        center: Alignment.center,
        radius: 0.3,
        colors: [
          Colors.white.withOpacity(0.8 * metallicness),
          Colors.white.withOpacity(0.3 * metallicness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      final highlightPaint = Paint()
        ..shader = highlightGradient.createShader(
          Rect.fromCenter(
            center: Offset(x, y),
            width: size.width * 0.4,
            height: size.height * 0.4,
          ),
        );
      
      canvas.drawCircle(Offset(x, y), size.width * 0.2, highlightPaint);
    }
  }

  /// Paints liquid flow patterns.
  void _paintLiquidFlow(Canvas canvas, Size size, double time) {
    final flowLines = 5;
    
    for (int i = 0; i < flowLines; i++) {
      final startX = (i / flowLines) * size.width;
      final endX = startX + sin(time + i) * size.width * 0.1;
      
      final path = Path();
      path.moveTo(startX, 0);
      
      // Create flowing curve
      for (int j = 0; j <= 10; j++) {
        final t = j / 10.0;
        final x = startX + (endX - startX) * t;
        final y = t * size.height;
        
        // Add wave effect
        final waveOffset = sin(time * 2 + i * pi / 3) * 20.0;
        path.lineTo(x + waveOffset, y);
      }
      
      final flowPaint = Paint()
        ..color = Colors.white.withOpacity(0.1 * metallicness)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(path, flowPaint);
    }
  }

  /// Paints surface imperfections based on roughness.
  void _paintSurfaceImperfections(Canvas canvas, Size size, double roughness) {
    if (roughness < 0.1) return; // Skip for very smooth surfaces
    
    final imperfectionCount = (roughness * 50).round();
    final random = Random(42); // Fixed seed for consistent pattern
    
    for (int i = 0; i < imperfectionCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 5.0 * roughness;
      final opacity = random.nextDouble() * 0.3 * roughness;
      
      final imperfectionPaint = Paint()
        ..color = Colors.black.withOpacity(opacity);
      
      canvas.drawCircle(Offset(x, y), radius, imperfectionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LiquidMetalEffect oldDelegate) {
    return metallicness != oldDelegate.metallicness ||
           roughness != oldDelegate.roughness ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 