import 'dart:developer' as d;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A glow pulse effect painter that creates breathing glow on hover/press.
///
/// This effect creates a pulsing glow that responds to interactions with
/// smooth breathing animations. Currently uses a simplified implementation
/// since shader compilation is not yet available.
///
/// ## Usage
///
/// ```dart
/// CustomPaint(
///   painter: GlowPulseEffect(
///     isActive: true,
///     glowColor: Colors.cyan,
///     pulseSpeed: 1.0,
///   ),
/// )
/// ```
class GlowPulseEffect extends BaseShaderPainter {
  /// Creates a glow pulse effect painter.
  ///
  /// [isActive] determines if the glow pulse is active.
  /// [glowColor] is the color of the glow effect.
  /// [pulseSpeed] controls the pulse animation speed (0.5 to 2.0).
  /// [intensity] controls the glow intensity (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  GlowPulseEffect({
    this.isActive = false,
    this.glowColor = Colors.cyan,
    this.pulseSpeed = 1.0,
    this.intensity = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
         shaderPath: 'glow_pulse.frag',
         performanceLevel: performanceLevel ?? PerformanceLevel.medium,
       );

  /// Whether the glow pulse is active.
  final bool isActive;

  /// Color of the glow effect.
  final Color glowColor;

  /// Pulse animation speed (0.5 to 2.0).
  final double pulseSpeed;

  /// Glow intensity (0.0 to 1.0).
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (isShaderLoaded) {
      // Use shader if available
      super.paint(canvas, size);
    } else {
      // Fallback to gradient implementation
      _paintGlowPulse(canvas, size);
    }
  }

  @override
  void setCustomUniforms(FragmentShader shader, int startIndex) {
    int floatIndex = startIndex;
    // Center of the glow
    shader.setFloat(floatIndex++, 0.5);
    shader.setFloat(floatIndex++, 0.5);

    // Size of the pulse
    shader.setFloat(floatIndex++, 10.0);

    // Color of the glow
    shader.setFloat(floatIndex++, 0.9);
    shader.setFloat(floatIndex++, 0.2);
    shader.setFloat(floatIndex++, 0.4);
    shader.setFloat(floatIndex++, 1.0);

    // Type of the glow pulse
    shader.setFloat(floatIndex++, 3);
  }

  /// Paints the glow pulse effect.
  void _paintGlowPulse(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * pulseSpeed;
    final center = Offset(size.width / 2, size.height / 2);

    if (isActive) {
      // Calculate pulse value (0.0 to 1.0)
      final pulseValue = (sin(time * 2) + 1.0) / 2.0;

      // Paint multiple glow layers
      _paintGlowLayers(canvas, size, center, pulseValue);

      // Paint pulse rings
      _paintPulseRings(canvas, size, center, time);

      // Paint center highlight
      _paintCenterHighlight(canvas, center, pulseValue);
    } else {
      // Paint subtle inactive glow
      _paintInactiveGlow(canvas, size, center);
    }
  }

  /// Paints multiple glow layers for depth.
  void _paintGlowLayers(
    Canvas canvas,
    Size size,
    Offset center,
    double pulseValue,
  ) {
    final maxRadius = min(size.width, size.height) * 0.8;
    final layerCount = 5;

    for (int i = 0; i < layerCount; i++) {
      final layerRadius = maxRadius * (0.3 + (i / layerCount) * 0.7);
      final layerOpacity =
          intensity * (1.0 - i / layerCount) * 0.4 * pulseValue;
      final layerBlur = (i + 1) * 3.0;

      // Create glow gradient
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          glowColor.withOpacity(layerOpacity),
          glowColor.withOpacity(layerOpacity * 0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCenter(
            center: center,
            width: layerRadius * 2,
            height: layerRadius * 2,
          ),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerBlur);

      canvas.drawCircle(center, layerRadius, paint);
    }
  }

  /// Paints expanding pulse rings.
  void _paintPulseRings(Canvas canvas, Size size, Offset center, double time) {
    final maxRadius = min(size.width, size.height) * 0.6;
    final ringCount = 3;

    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (time + i * 0.5) % 2.0 / 2.0;
      final ringRadius = maxRadius * ringProgress;
      final ringOpacity = intensity * (1.0 - ringProgress) * 0.6;

      if (ringOpacity > 0.01) {
        final paint = Paint()
          ..color = glowColor.withOpacity(ringOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawCircle(center, ringRadius, paint);
      }
    }
  }

  /// Paints the center highlight.
  void _paintCenterHighlight(Canvas canvas, Offset center, double pulseValue) {
    // Create center glow
    final centerGlowPaint = Paint()
      ..color = glowColor.withOpacity(intensity * 0.8 * pulseValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, 20.0, centerGlowPaint);

    // Create center core
    final centerCorePaint = Paint()
      ..color = glowColor.withOpacity(intensity * pulseValue);

    canvas.drawCircle(center, 8.0, centerCorePaint);
  }

  /// Paints subtle inactive glow.
  void _paintInactiveGlow(Canvas canvas, Size size, Offset center) {
    final maxRadius = min(size.width, size.height) * 0.3;

    // Create subtle inactive glow
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [glowColor.withOpacity(intensity * 0.1), Colors.transparent],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: center,
          width: maxRadius * 2,
          height: maxRadius * 2,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(center, maxRadius, paint);
  }

  @override
  bool shouldRepaint(covariant GlowPulseEffect oldDelegate) {
    return isActive != oldDelegate.isActive ||
        glowColor != oldDelegate.glowColor ||
        pulseSpeed != oldDelegate.pulseSpeed ||
        intensity != oldDelegate.intensity ||
        performanceLevel != oldDelegate.performanceLevel;
  }
}
