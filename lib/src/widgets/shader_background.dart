import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';
import '../effects/background/plasma_effect.dart';

/// A widget that displays shader effects as a background.
/// 
/// This widget provides easy-to-use background effects with a simple API.
/// It automatically handles performance optimization and provides graceful
/// fallbacks when shaders fail to load.
/// 
/// ## Usage
/// 
/// ```dart
/// // Simple plasma background
/// ShaderBackground.plasma()
/// 
/// // Customized plasma background
/// ShaderBackground.plasma(
///   colors: [Colors.purple, Colors.cyan],
///   speed: 1.5,
///   intensity: 0.8,
/// )
/// 
/// // Custom shader background
/// ShaderBackground.custom(
///   shader: 'my_effect.frag',
///   uniforms: {
///     'u_color1': Colors.red,
///     'u_color2': Colors.blue,
///     'u_speed': 2.0,
///   },
/// )
/// ```
class ShaderBackground extends StatefulWidget {
  /// Creates a shader background with a custom shader.
  /// 
  /// [shader] should be the path to the GLSL fragment shader file.
  /// [uniforms] are the uniform values to pass to the shader.
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.custom({
    super.key,
    required this.shader,
    this.uniforms = const {},
    this.child,
    this.performanceLevel,
  }) : effectType = null,
       colors = const [],
       speed = 1.0,
       intensity = 1.0;

  /// Creates a plasma background effect.
  /// 
  /// [colors] are the colors to use for the plasma effect.
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.plasma({
    super.key,
    this.colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
    this.speed = 1.0,
    this.intensity = 1.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.plasma,
       shader = null,
       uniforms = const {};

  /// The type of shader effect to use.
  final ShaderEffectType? effectType;

  /// The path to the custom GLSL shader file.
  final String? shader;

  /// Uniform values to pass to the shader.
  final Map<String, dynamic> uniforms;

  /// Colors for the effect (used by predefined effects).
  final List<Color> colors;

  /// Animation speed for the effect (0.0 to 2.0).
  final double speed;

  /// Effect intensity (0.0 to 1.0).
  final double intensity;

  /// The widget to display on top of the background.
  final Widget? child;

  /// Performance level for the effect.
  final PerformanceLevel? performanceLevel;

  @override
  State<ShaderBackground> createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground>
    with TickerProviderStateMixin {
  late EffectController _controller;
  late PerformanceManager _performanceManager;
  BaseShaderPainter? _painter;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializePerformanceManager();
    _createPainter();
  }

  void _initializeController() {
    _controller = EffectController();
    
    // Set initial values
    if (widget.colors.isNotEmpty) {
      _controller.setColor1(widget.colors.first);
      if (widget.colors.length > 1) {
        _controller.setColor2(widget.colors[1]);
      }
    }
    _controller.setIntensity(widget.intensity);
  }

  void _initializePerformanceManager() {
    _performanceManager = PerformanceManager(
      forcePerformanceLevel: widget.performanceLevel,
    );
  }

  void _createPainter() {
    if (widget.effectType == ShaderEffectType.plasma) {
      _painter = PlasmaEffect(
        colors: widget.colors,
        speed: widget.speed,
        intensity: widget.intensity,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.shader != null) {
      // For custom shaders, we'll create a basic painter
      // This will be enhanced when we have more effect types
      _painter = _CustomShaderPainter(
        shaderPath: widget.shader!,
        uniforms: widget.uniforms,
        performanceLevel: _performanceManager.performanceLevel,
      );
    }
  }

  @override
  void didUpdateWidget(ShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller if values changed
    if (widget.colors != oldWidget.colors && widget.colors.isNotEmpty) {
      _controller.setColor1(widget.colors.first);
      if (widget.colors.length > 1) {
        _controller.setColor2(widget.colors[1]);
      }
    }
    
    if (widget.intensity != oldWidget.intensity) {
      _controller.setIntensity(widget.intensity);
    }
    
    // Recreate painter if effect type or shader changed
    if (widget.effectType != oldWidget.effectType ||
        widget.shader != oldWidget.shader) {
      _createPainter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _painter,
          child: widget.child ?? const SizedBox.expand(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _painter?.dispose();
    super.dispose();
  }
}

/// Custom shader painter for user-provided shaders.
/// 
/// This is a basic implementation that will be enhanced as the package
/// develops more sophisticated shader handling capabilities.
class _CustomShaderPainter extends BaseShaderPainter {
  _CustomShaderPainter({
    required super.shaderPath,
    required super.uniforms,
    required super.performanceLevel,
  });

  @override
  void _setCustomUniforms(FragmentShader shader) {
    // Set custom uniforms from the uniforms map
    for (final entry in uniforms.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is num) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting uniform $key to number $value');
      } else if (value is Color) {
        // Note: This will be implemented when FragmentShader API is available
        // For now, we'll just log the uniform
        debugPrint('Setting uniform $key to color $value');
      } else if (value is Offset) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting uniform $key to offset $value');
      } else if (value is Size) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting uniform $key to size $value');
      }
    }
  }
}

/// Types of shader effects available.
enum ShaderEffectType {
  /// Plasma effect with flowing colors.
  plasma,
  
  /// Noise field effect with Perlin noise patterns.
  noiseField,
  
  /// Liquid metal effect with reflective surface.
  liquidMetal,
  
  /// Fractal effect with Mandelbrot/Julia variations.
  fractal,
  
  /// Particle field effect with floating particles.
  particleField,
  
  /// Wave effect with sine wave interference.
  wave,
  
  /// Galaxy effect with spiral galaxy and stars.
  galaxy,
  
  /// Aurora effect with northern lights.
  aurora,
} 