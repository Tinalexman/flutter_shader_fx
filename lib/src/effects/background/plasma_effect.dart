import 'dart:ui';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A plasma effect painter that creates flowing, organic color patterns.
///
/// This effect simulates plasma-like flowing colors using mathematical
/// functions to create smooth, animated gradients.
///
/// ## Usage
///
/// ```dart
/// CustomPainter(
///   painter: PlasmaEffect(
///     colors: [Colors.purple, Colors.cyan],
///     speed: 1.0,
///     intensity: 0.8,
///     performanceLevel: PerformanceLevel.low,
///   ),
///   touchPosition: () => Offset(0.5, 0.5),
/// )
/// ```
class PlasmaEffect extends BaseShaderPainter {
  /// Creates a plasma effect painter.
  ///
  /// [colors] are the colors to use for the plasma effect.
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  /// [performanceLevel] determines the quality settings.
  PlasmaEffect({
    required this.colors,
    this.speed = 1.0,
    this.intensity = 1.0,
    this.touchPosition,
    PerformanceLevel? performanceLevel,
  }) : super(
         shaderPath: 'plasma.frag',
         uniforms: {
           'u_intensity': intensity,
           'u_color1': colors.isNotEmpty ? colors[0] : const Color(0xFF9C27B0),
           'u_color2': colors.length > 1 ? colors[1] : const Color(0xFF00BCD4),
           'u_speed': speed,
         },
         performanceLevel: performanceLevel ?? PerformanceLevel.medium,
       );

  /// Colors for the plasma effect.
  final List<Color> colors;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  /// Touch/mouse position for interaction (normalized 0.0-1.0).
  final Offset Function()? touchPosition;

  @override
  Offset getTouchPosition() {
    return touchPosition?.call() ?? Offset.zero;
  }

  @override
  void setCustomUniforms(FragmentShader shader, int startIndex) {
    int floatIndex = startIndex;

    Offset touchPos = getTouchPosition();
    shader.setFloat(floatIndex++, touchPos.dx);
    shader.setFloat(floatIndex++, touchPos.dy);

    Color color1 = uniforms['u_color1'] as Color? ?? const Color(0xFF9C27B0);
    Color color2 = uniforms['u_color2'] as Color? ?? const Color(0xFF00BCD4);

    shader.setFloat(floatIndex++, color1.r);
    shader.setFloat(floatIndex++, color1.g);
    shader.setFloat(floatIndex++, color1.b);
    shader.setFloat(floatIndex++, color1.a);

    shader.setFloat(floatIndex++, color2.r);
    shader.setFloat(floatIndex++, color2.g);
    shader.setFloat(floatIndex++, color2.b);
    shader.setFloat(floatIndex++, color2.a);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (isShaderLoaded) {
      super.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant PlasmaEffect oldDelegate) {
    int oldColorsHashCode = colors.hashCode;
    int newColorsHashCode = oldDelegate.colors.hashCode;
    return oldColorsHashCode != newColorsHashCode ||
        speed != oldDelegate.speed ||
        intensity != oldDelegate.intensity ||
        performanceLevel != oldDelegate.performanceLevel;
  }
}
