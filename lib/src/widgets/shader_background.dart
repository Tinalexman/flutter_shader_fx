import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';
import '../effects/background/plasma_effect.dart';
import '../effects/background/noise_field_effect.dart';
import '../effects/background/liquid_metal_effect.dart';
import '../effects/background/fractal_effect.dart';
import '../effects/background/particle_field_effect.dart';
import '../effects/background/wave_effect.dart';
import '../effects/background/galaxy_effect.dart';
import '../effects/background/aurora_effect.dart';

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
       intensity = 1.0,
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

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
       uniforms = const {},
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a noise field background effect.
  /// 
  /// [scale] controls the scale of the noise pattern (higher = smaller details).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [intensity] controls the effect intensity (0.0 to 1.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.noiseField({
    super.key,
    this.scale = 50.0,
    this.speed = 1.0,
    this.intensity = 1.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.noiseField,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a liquid metal background effect.
  /// 
  /// [metallicness] controls the metallic appearance (0.0 to 1.0).
  /// [roughness] controls the surface roughness (0.0 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.liquidMetal({
    super.key,
    this.metallicness = 0.8,
    this.roughness = 0.2,
    this.speed = 1.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.liquidMetal,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       intensity = 1.0,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a fractal background effect.
  /// 
  /// [zoom] controls the zoom level (higher = more zoomed in).
  /// [center] is the center point of the fractal (normalized coordinates).
  /// [maxIterations] is the maximum number of iterations for fractal calculation.
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.fractal({
    super.key,
    this.zoom = 1.0,
    this.center = const Offset(0.5, 0.5),
    this.maxIterations = 100,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.fractal,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       intensity = 1.0,
       speed = 1.0,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a particle field background effect.
  /// 
  /// [particleCount] is the number of particles to display.
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [size] controls the size of particles (0.5 to 5.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.particleField({
    super.key,
    this.particleCount = 100,
    this.speed = 1.0,
    this.particleSize = 2.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.particleField,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       intensity = 1.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a wave background effect.
  /// 
  /// [frequency] controls the wave frequency (0.5 to 5.0).
  /// [amplitude] controls the wave amplitude (0.1 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.wave({
    super.key,
    this.frequency = 2.0,
    this.amplitude = 0.5,
    this.speed = 1.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.wave,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       intensity = 1.0,
       starCount = 200,
       spiralArms = 4,
       layers = 3;

  /// Creates a galaxy background effect.
  /// 
  /// [starCount] is the number of stars to display.
  /// [spiralArms] is the number of spiral arms (2 to 6).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.galaxy({
    super.key,
    this.starCount = 200,
    this.spiralArms = 4,
    this.speed = 1.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.galaxy,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       intensity = 1.0,
       layers = 3;

  /// Creates an aurora background effect.
  /// 
  /// [intensity] controls the aurora intensity (0.0 to 1.0).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [layers] is the number of aurora layers (1 to 5).
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.aurora({
    super.key,
    this.intensity = 0.8,
    this.speed = 1.0,
    this.layers = 3,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderEffectType.aurora,
       shader = null,
       uniforms = const {},
       colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
       scale = 50.0,
       metallicness = 0.8,
       roughness = 0.2,
       zoom = 1.0,
       center = const Offset(0.5, 0.5),
       maxIterations = 100,
       particleCount = 100,
       particleSize = 2.0,
       frequency = 2.0,
       amplitude = 0.5,
       starCount = 200,
       spiralArms = 4;

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

  /// Scale for noise field effect (higher = smaller details).
  final double scale;

  /// Metallicness for liquid metal effect (0.0 to 1.0).
  final double metallicness;

  /// Roughness for liquid metal effect (0.0 to 1.0).
  final double roughness;

  /// Zoom level for fractal effect (higher = more zoomed in).
  final double zoom;

  /// Center point for fractal effect (normalized coordinates).
  final Offset center;

  /// Maximum iterations for fractal effect.
  final int maxIterations;

  /// Particle count for particle field effect.
  final int particleCount;

  /// Particle size for particle field effect (0.5 to 5.0).
  final double particleSize;

  /// Wave frequency for wave effect (0.5 to 5.0).
  final double frequency;

  /// Wave amplitude for wave effect (0.1 to 1.0).
  final double amplitude;

  /// Star count for galaxy effect.
  final int starCount;

  /// Spiral arms for galaxy effect (2 to 6).
  final int spiralArms;

  /// Aurora layers for aurora effect (1 to 5).
  final int layers;

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
    } else if (widget.effectType == ShaderEffectType.noiseField) {
      _painter = NoiseFieldEffect(
        scale: widget.scale,
        speed: widget.speed,
        intensity: widget.intensity,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.liquidMetal) {
      _painter = LiquidMetalEffect(
        metallicness: widget.metallicness,
        roughness: widget.roughness,
        speed: widget.speed,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.fractal) {
      _painter = FractalEffect(
        zoom: widget.zoom,
        center: widget.center,
        maxIterations: widget.maxIterations,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.particleField) {
      _painter = ParticleFieldEffect(
        particleCount: widget.particleCount,
        speed: widget.speed,
        size: widget.particleSize,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.wave) {
      _painter = WaveEffect(
        frequency: widget.frequency,
        amplitude: widget.amplitude,
        speed: widget.speed,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.galaxy) {
      _painter = GalaxyEffect(
        starCount: widget.starCount,
        spiralArms: widget.spiralArms,
        speed: widget.speed,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderEffectType.aurora) {
      _painter = AuroraEffect(
        intensity: widget.intensity,
        speed: widget.speed,
        layers: widget.layers,
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