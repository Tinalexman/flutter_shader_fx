import 'dart:ui';
import 'package:flutter/material.dart';

import 'performance_manager.dart';

/// Base class for all shader painters in the Flutter Shader FX package.
///
/// This class provides common functionality for loading and managing GLSL shaders,
/// handling uniforms, and ensuring proper performance optimization for mobile devices.
///
/// All custom shader painters should extend this class and implement the required
/// methods for their specific effects.
abstract class BaseShaderPainter extends CustomPainter {
  /// Creates a base shader painter.
  ///
  /// [shaderPath] should be the path to the GLSL fragment shader file relative
  /// to the shaders/ directory.
  BaseShaderPainter({
    required this.shaderPath,
    this.uniforms = const {},
    this.performanceLevel = PerformanceLevel.medium,
  });

  /// Path to the GLSL fragment shader file.
  final String shaderPath;

  /// Map of uniform values to pass to the shader.
  ///
  /// Keys should match uniform names in the GLSL shader.
  /// Values can be numbers, colors, or other supported types.
  final Map<String, dynamic> uniforms;

  /// Performance level for the shader effect.
  ///
  /// This affects quality settings and optimization strategies.
  final PerformanceLevel performanceLevel;

  /// The compiled fragment shader.
  FragmentShader? _fragmentShader;

  /// The start time of the shader effect.
  final DateTime _startTime = DateTime.now();

  /// Whether the shader has been loaded and compiled.
  bool get isShaderLoaded => _fragmentShader != null;

  /// Loads and compiles the GLSL shader.
  ///
  /// This method should be called before painting. It handles shader compilation
  /// and provides error handling for compilation failures.
  Future<void> loadShader() async {
    if (_fragmentShader != null) return;

    try {
      // Load shader using FragmentProgram (modern approach)
      FragmentProgram program = await FragmentProgram.fromAsset(
        'packages/flutter_shader_fx/shaders/$shaderPath',
      );

      _fragmentShader = program.fragmentShader();
    } catch (e) {
      // Log error but don't crash - fall back to solid color
      debugPrint('Failed to compile shader $shaderPath: $e');
      _fragmentShader = null;
    }
  }

  /// Sets up the shader uniforms before painting.
  ///
  /// This method should be called in the paint method to configure
  /// all uniform values for the current frame.
  void _setupUniforms(Canvas canvas, Size size) {
    if (_fragmentShader == null) return;

    final shader = _fragmentShader!;
    int floatIndex = 0;

    // Set standard uniforms
    shader.setFloat(floatIndex++, size.width);
    shader.setFloat(floatIndex++, size.height);

    DateTime currentTime = DateTime.now();
    double elapsed = currentTime.difference(_startTime).inMilliseconds / 1000.0;
    shader.setFloat(floatIndex++, elapsed);

    // Set touch position (normalized coordinates)
    final touchPos = getTouchPosition();
    shader.setFloat(floatIndex++, touchPos.dx);
    shader.setFloat(floatIndex++, touchPos.dy);

    // Set intensity (default to 1.0)
    shader.setFloat(
      floatIndex++,
      (uniforms['u_intensity'] as num?)?.toDouble() ?? 1.0,
    );

    // Set colors (default to purple and cyan)
    final color1 = uniforms['u_color1'] as Color? ?? const Color(0xFF9C27B0);
    final color2 = uniforms['u_color2'] as Color? ?? const Color(0xFF00BCD4);

    shader.setFloat(floatIndex++, color1.r);
    shader.setFloat(floatIndex++, color1.g);
    shader.setFloat(floatIndex++, color1.b);
    shader.setFloat(floatIndex++, color1.a);

    shader.setFloat(floatIndex++, color2.r);
    shader.setFloat(floatIndex++, color2.g);
    shader.setFloat(floatIndex++, color2.b);
    shader.setFloat(floatIndex++, color2.a);

    // Set custom uniforms
    setCustomUniforms(shader, floatIndex);
  }

  /// Gets the current touch position in normalized coordinates (0.0 to 1.0).
  ///
  /// Override this method to provide touch input for interactive effects.
  Offset getTouchPosition() {
    // Default implementation returns center of screen
    return const Offset(0.5, 0.5);
  }

  /// Sets custom uniforms specific to this shader effect.
  ///
  /// Override this method to set any additional uniforms beyond the standard ones.
  /// [startIndex] is the next available float uniform index.
  void setCustomUniforms(FragmentShader shader, int startIndex) {}

  @override
  void paint(Canvas canvas, Size size) {
    if (_fragmentShader == null) {
      // Fall back to solid color if shader failed to load
      _paintFallback(canvas, size);
      return;
    }

    _setupUniforms(canvas, size);

    // Create a paint object with the shader
    final paint = Paint()
      ..shader = _fragmentShader
      ..filterQuality = FilterQuality.high;

    // Draw the full canvas with the shader
    canvas.drawRect(Offset.zero & size, paint);
  }

  /// Fallback painting method when shader fails to load.
  ///
  /// This provides a graceful degradation to a solid color or gradient
  /// when shader compilation fails.
  void _paintFallback(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          uniforms['u_color1'] as Color? ?? const Color(0xFF9C27B0),
          uniforms['u_color2'] as Color? ?? const Color(0xFF00BCD4),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant BaseShaderPainter oldDelegate) => true;

  /// Disposes of shader resources.
  void dispose() {
    _fragmentShader?.dispose();
  }
}
