import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'performance_manager.dart';

/// Base class for all shader painters in the Flutter Shader FX package.
/// 
/// This class provides common functionality for loading and managing GLSL shaders,
/// handling uniforms, and ensuring proper performance optimization for mobile devices.
/// 
/// All custom shader painters should extend this class and implement the required
/// methods for their specific effects.
@immutable
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

  /// Whether the shader has been loaded and compiled.
  bool get isShaderLoaded => _fragmentShader != null;

  /// Loads and compiles the GLSL shader.
  /// 
  /// This method should be called before painting. It handles shader compilation
  /// and provides error handling for compilation failures.
  Future<void> loadShader() async {
    if (_fragmentShader != null) return;

    try {
      final shaderSource = await _loadShaderSource();
      // FragmentProgram program = await FragmentProgram.fromAsset(
      //   'packages/flutter_shader_fx/shaders/$shaderPath'
      // );

      // _fragmentShader = program.fragmentShader;
      _fragmentShader = await FragmentShader.compile(
        shaderSource,
        uniformFloatCount: _getUniformFloatCount(),
        uniformIntCount: _getUniformIntCount(),
      );
    } catch (e) {
      // Log error but don't crash - fall back to solid color
      debugPrint('Failed to compile shader $shaderPath: $e');
      _fragmentShader = null;
    }
  }

  /// Loads the GLSL shader source code from the assets.
  Future<String> _loadShaderSource() async {
    final assetPath = 'packages/flutter_shader_fx/shaders/$shaderPath';
    return await rootBundle.loadString(assetPath);
  }

  /// Gets the number of float uniforms used by this shader.
  /// 
  /// Override this method to specify the exact number of float uniforms
  /// your shader uses for optimal performance.
  int _getUniformFloatCount() {
    // Default implementation counts common uniforms
    int count = 0;
    
    // Standard uniforms (locations 0-5)
    count += 6; // u_resolution, u_time, u_touch, u_intensity, u_color1, u_color2
    
    // Count additional float uniforms from the uniforms map
    for (final value in uniforms.values) {
      if (value is num) count++;
      if (value is Color) count += 4; // RGBA
      if (value is Offset) count += 2; // x, y
      if (value is Size) count += 2; // width, height
    }
    
    return count;
  }

  /// Gets the number of integer uniforms used by this shader.
  /// 
  /// Override this method to specify the exact number of integer uniforms
  /// your shader uses for optimal performance.
  int _getUniformIntCount() {
    // Most shaders don't use integer uniforms by default
    return 0;
  }

  /// Sets up the shader uniforms before painting.
  /// 
  /// This method should be called in the paint method to configure
  /// all uniform values for the current frame.
  void _setupUniforms(Canvas canvas, Size size) {
    if (_fragmentShader == null) return;

    final shader = _fragmentShader!;
    
    // Set standard uniforms (locations 0-5)
    shader.setFloat('u_resolution', size.width, size.height);
    shader.setFloat('u_time', DateTime.now().millisecondsSinceEpoch / 1000.0);
    
    // Set touch position (normalized coordinates)
    final touchPos = _getTouchPosition();
    shader.setFloat('u_touch', touchPos.dx, touchPos.dy);
    
    // Set intensity (default to 1.0)
    shader.setFloat('u_intensity', uniforms['u_intensity'] ?? 1.0);
    
    // Set colors (default to purple and cyan)
    final color1 = uniforms['u_color1'] ?? const Color(0xFF9C27B0);
    final color2 = uniforms['u_color2'] ?? const Color(0xFF00BCD4);
    shader.setFloat('u_color1', 
      color1.red / 255.0, 
      color1.green / 255.0, 
      color1.blue / 255.0, 
      color1.alpha / 255.0
    );
    shader.setFloat('u_color2', 
      color2.red / 255.0, 
      color2.green / 255.0, 
      color2.blue / 255.0, 
      color2.alpha / 255.0
    );
    
    // Set custom uniforms
    _setCustomUniforms(shader);
  }

  /// Gets the current touch position in normalized coordinates (0.0 to 1.0).
  /// 
  /// Override this method to provide touch input for interactive effects.
  Offset _getTouchPosition() {
    // Default implementation returns center of screen
    return const Offset(0.5, 0.5);
  }

  /// Sets custom uniforms specific to this shader effect.
  /// 
  /// Override this method to set any additional uniforms beyond the standard ones.
  void _setCustomUniforms(FragmentShader shader) {
    // Default implementation does nothing
    // Override in subclasses to set effect-specific uniforms
  }

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
      ..shader = _fragmentShader!
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
          uniforms['u_color1'] ?? const Color(0xFF9C27B0),
          uniforms['u_color2'] ?? const Color(0xFF00BCD4),
        ],
      ).createShader(Offset.zero & size);
    
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant BaseShaderPainter oldDelegate) {
    return shaderPath != oldDelegate.shaderPath ||
           uniforms != oldDelegate.uniforms ||
           performanceLevel != oldDelegate.performanceLevel;
  }

  @override
  void dispose() {
    _fragmentShader?.dispose();
    super.dispose();
  }
}
