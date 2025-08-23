import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A depth shadow effect painter that creates 3D depth illusion for flat surfaces.
/// 
/// This effect creates realistic shadows and depth perception for flat surfaces
/// with customizable light sources. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: DepthShadowEffect(
///     lightPosition: Offset(0.3, 0.2),
///     shadowIntensity: 0.8,
///     depth: 0.5,
///   ),
/// )
/// ```
class DepthShadowEffect extends BaseShaderPainter {
  /// Creates a depth shadow effect painter.
  /// 
  /// [lightPosition] is the position of the light source (normalized coordinates).
  /// [shadowIntensity] controls the shadow intensity (0.0 to 1.0).
  /// [depth] controls the depth effect (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  DepthShadowEffect({
    this.lightPosition = const Offset(0.3, 0.2),
    this.shadowIntensity = 0.8,
    this.depth = 0.5,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'depth_shadow.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Position of the light source (normalized coordinates).
  final Offset lightPosition;

  /// Shadow intensity (0.0 to 1.0).
  final double shadowIntensity;

  /// Depth effect (0.0 to 1.0).
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    _paintDepthShadow(canvas, size);
  }

  /// Paints the depth shadow effect.
  void _paintDepthShadow(Canvas canvas, Size size) {
    // Paint base surface
    _paintBaseSurface(canvas, size);
    
    // Paint depth shadows
    _paintDepthShadows(canvas, size);
    
    // Paint light highlights
    _paintLightHighlights(canvas, size);
    
    // Paint ambient occlusion
    _paintAmbientOcclusion(canvas, size);
  }

  /// Paints the base surface.
  void _paintBaseSurface(Canvas canvas, Size size) {
    final surfaceRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Create surface gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.grey.withOpacity(0.1),
        Colors.grey.withOpacity(0.3),
        Colors.grey.withOpacity(0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(surfaceRect);
    
    canvas.drawRect(surfaceRect, paint);
  }

  /// Paints depth shadows.
  void _paintDepthShadows(Canvas canvas, Size size) {
    final lightPos = Offset(
      lightPosition.dx * size.width,
      lightPosition.dy * size.height,
    );
    
    // Create multiple shadow layers for depth
    final shadowLayers = 5;
    
    for (int layer = 0; layer < shadowLayers; layer++) {
      final layerDepth = depth * (layer + 1) / shadowLayers;
      final shadowOffset = Offset(
        lightPos.dx * layerDepth * 0.1,
        lightPos.dy * layerDepth * 0.1,
      );
      
      final shadowRect = Rect.fromLTWH(
        shadowOffset.dx,
        shadowOffset.dy,
        size.width - shadowOffset.dx,
        size.height - shadowOffset.dy,
      );
      
      final shadowOpacity = shadowIntensity * (1.0 - layer / shadowLayers) * 0.3;
      
      final paint = Paint()
        ..color = Colors.black.withOpacity(shadowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + layer * 2);
      
      canvas.drawRect(shadowRect, paint);
    }
  }

  /// Paints light highlights.
  void _paintLightHighlights(Canvas canvas, Size size) {
    final lightPos = Offset(
      lightPosition.dx * size.width,
      lightPosition.dy * size.height,
    );
    
    // Create light source glow
    final glowRadius = min(size.width, size.height) * 0.2;
    
    final glowGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromCenter(
          center: lightPos,
          width: glowRadius * 2,
          height: glowRadius * 2,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(lightPos, glowRadius, glowPaint);
    
    // Create specular highlights
    _paintSpecularHighlights(canvas, size, lightPos);
  }

  /// Paints specular highlights.
  void _paintSpecularHighlights(Canvas canvas, Size size, Offset lightPos) {
    final highlightCount = 3;
    
    for (int i = 0; i < highlightCount; i++) {
      final highlightPos = Offset(
        (i / highlightCount) * size.width + size.width * 0.1,
        size.height * 0.2 + i * size.height * 0.05,
      );
      
      final toLight = lightPos - highlightPos;
      final distance = toLight.distance;
      final intensity = 1.0 / (distance + 1.0) * depth;
      
      if (intensity > 0.1) {
        final highlightRadius = 20.0 * intensity;
        
        final highlightGradient = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.white.withOpacity(intensity * 0.8),
            Colors.white.withOpacity(intensity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
        
        final paint = Paint()
          ..shader = highlightGradient.createShader(
            Rect.fromCenter(
              center: highlightPos,
              width: highlightRadius * 2,
              height: highlightRadius * 2,
            ),
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawCircle(highlightPos, highlightRadius, paint);
      }
    }
  }

  /// Paints ambient occlusion.
  void _paintAmbientOcclusion(Canvas canvas, Size size) {
    // Create ambient occlusion in corners
    final cornerRadius = min(size.width, size.height) * 0.1;
    
    // Top-left corner
    _paintCornerOcclusion(canvas, Offset(0, 0), cornerRadius);
    
    // Top-right corner
    _paintCornerOcclusion(canvas, Offset(size.width, 0), cornerRadius);
    
    // Bottom-left corner
    _paintCornerOcclusion(canvas, Offset(0, size.height), cornerRadius);
    
    // Bottom-right corner
    _paintCornerOcclusion(canvas, Offset(size.width, size.height), cornerRadius);
  }

  /// Paints corner occlusion.
  void _paintCornerOcclusion(Canvas canvas, Offset corner, double radius) {
    final occlusionRect = Rect.fromCenter(
      center: corner,
      width: radius * 2,
      height: radius * 2,
    );
    
    final occlusionGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.black.withOpacity(0.4 * shadowIntensity),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
    
    final paint = Paint()
      ..shader = occlusionGradient.createShader(occlusionRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawRect(occlusionRect, paint);
  }

  @override
  bool shouldRepaint(covariant DepthShadowEffect oldDelegate) {
    return lightPosition != oldDelegate.lightPosition ||
           shadowIntensity != oldDelegate.shadowIntensity ||
           depth != oldDelegate.depth ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 