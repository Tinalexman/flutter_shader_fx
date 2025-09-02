import 'dart:ui' as ui show Image, FragmentShader;
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';

/// A distortion effect painter
///
/// ## Usage
///
/// ```dart
/// CustomPainter(
///   painter: Distortion(
///     speed: 1.0,
///     intensity: 0.8,
///     image: image,
///     touchPosition: () => Offset(0.5, 0.5),
///   ),
/// )
/// ```
class Distortion extends BaseShaderPainter {
  /// Creates a distortion effect painter.
  ///
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  Distortion({
    this.speed = 1.0,
    this.intensity = 1.0,
    this.touchPosition,
    this.image,
    super.deviceDensity = 1.0,
  }) : super(
         shaderPath: 'effect/distortion.frag',
         uniforms: {'u_intensity': intensity, 'u_speed': speed},
       );

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  /// The captured image of the child
  final ui.Image? image;

  /// Touch/mouse position for interaction (normalized 0.0-1.0).
  final Offset Function()? touchPosition;

  @override
  Offset getTouchPosition() {
    return touchPosition?.call() ?? Offset.zero;
  }

  @override
  void setCustomUniforms(ui.FragmentShader shader, int _) {
    if (image != null) {
      shader.setImageSampler(0, image!);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    if (isShaderLoaded) {
      super.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant Distortion oldDelegate) {
    return speed != oldDelegate.speed ||
        intensity != oldDelegate.intensity ||
        image != oldDelegate.image;
  }
}
