import 'dart:ui';

import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A digital glitch effect painter that creates cyberpunk-style glitch artifacts.
///
/// This effect simulates digital corruption with RGB channel splitting, scanlines,
/// pixel displacement, and random artifacts. Perfect for cyberpunk, retro, or
/// glitch art aesthetics.
///
/// ## Usage
///
/// ```dart
/// CustomPaint(
///   painter: DigitalGlitchEffect(
///     colors: [Colors.cyan, Colors.magenta],
///     intensity: 0.8,
///     speed: 1.5,
///     touchPosition: () => Offset(0.5, 0.5),
///   ),
/// )
/// ```
class GlitchEffect extends BaseShaderPainter {
  /// Creates a digital glitch effect painter.
  ///
  /// [colors] are the colors to use for the glitch effect.
  /// [intensity] controls the glitch intensity (0.0 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [glitchType] determines the type of glitch artifacts.
  /// [touchPosition] is the touch/mouse position for interactive glitch.
  /// [performanceLevel] determines the quality settings.
  GlitchEffect({
    required this.colors,
    this.intensity = 0.8,
    this.speed = 1.0,
    this.glitchType = GlitchType.digital,
    this.touchPosition,
    PerformanceLevel? performanceLevel,
  }) : super(
         shaderPath: 'glitch.frag',
         uniforms: {
           'u_intensity': intensity,
           'u_color1': colors.isNotEmpty ? colors[0] : const Color(0xFF00FFFF),
           'u_color2': colors.length > 1 ? colors[1] : const Color(0xFFFF00FF),
           'u_speed': speed,
           'u_glitch_type': glitchType.index.toDouble(),
         },
         performanceLevel: performanceLevel ?? PerformanceLevel.medium,
       );

  /// Colors for the glitch effect.
  final List<Color> colors;

  /// Glitch intensity (0.0 to 1.0).
  final double intensity;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Type of glitch effect to apply.
  final GlitchType glitchType;

  /// Touch/mouse position for interaction (normalized 0.0-1.0).
  final Offset Function()? touchPosition;

  @override
  Offset getTouchPosition() {
    return touchPosition?.call() ?? Offset.zero;
  }

  @override
  void setCustomUniforms(FragmentShader shader, int startIndex) {
    int floatIndex = startIndex;

    // Set touch position (normalized coordinates)
    Offset touchPos = getTouchPosition();
    shader.setFloat(floatIndex++, touchPos.dx);
    shader.setFloat(floatIndex++, touchPos.dy);
    
    // Set colors (default to cyan and magenta for cyberpunk look)
    Color color1 = uniforms['u_color1'] as Color? ?? const Color(0xFF00FFFF);
    Color color2 = uniforms['u_color2'] as Color? ?? const Color(0xFFFF00FF);

    shader.setFloat(floatIndex++, color1.r);
    shader.setFloat(floatIndex++, color1.g);
    shader.setFloat(floatIndex++, color1.b);
    shader.setFloat(floatIndex++, color1.a);

    shader.setFloat(floatIndex++, color2.r);
    shader.setFloat(floatIndex++, color2.g);
    shader.setFloat(floatIndex++, color2.b);
    shader.setFloat(floatIndex++, color2.a);

    // Set glitch type
    shader.setFloat(floatIndex++, glitchType.index.toDouble());
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isShaderLoaded) {
      super.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant GlitchEffect oldDelegate) {
    return colors != oldDelegate.colors ||
        intensity != oldDelegate.intensity ||
        speed != oldDelegate.speed ||
        glitchType != oldDelegate.glitchType ||
        touchPosition != oldDelegate.touchPosition ||
        performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Types of glitch effects available.
enum GlitchType {
  /// Digital glitch with RGB splitting and artifacts.
  digital,

  /// Analog glitch with VHS-style artifacts.
  analog,

  /// Data corruption with random pixel corruption.
  corruption,

  /// Screen tearing with horizontal displacement.
  tearing,

  /// Glitch wave that sweeps across the screen.
  wave,
}
