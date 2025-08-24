import 'dart:developer';
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
  int _repaintKey = 0; // Key to force repaints

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializePerformanceManager();
    _createPainter();

    // Start periodic updates for continuous animation
    _startContinuousAnimation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShaderAsync();
    });
  }

  Future<void> _loadShaderAsync() async {
    if (_painter != null) {
      await _painter!.loadShader();
      if (mounted) {
        setState(() => _repaintKey++);
      }
    }
  }

  void _initializeController() {
    _controller = EffectController(autoDispose: false);
    _controller.addListener(() {
      if (mounted) {
        setState(() => _repaintKey++);
      }
    });

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

  void _startContinuousAnimation() {
    // // Start periodic updates for shader animation
    _controller.startPeriodicUpdates(
      frequency: (100 / _getTargetFPS()).toInt(),
      callback: (time) {
        // This will trigger repaints for animated effects
        if (mounted && !_controller.isDisposed) {
          // The controller will notify listeners automatically
        }
      },
    );
  }

  void _createPainter() {
    // Dispose old painter first
    _painter?.dispose();

    if (widget.effectType == ShaderEffectType.plasma) {
      _painter = PlasmaEffect(
        colors: widget.colors,
        speed: widget.speed,
        intensity: widget.intensity,
        performanceLevel: _performanceManager.performanceLevel,
      );
    }
    // ... other effect types remain the same
    else if (widget.shader != null) {
      _painter = _CustomShaderPainter(
        shaderPath: widget.shader!,
        uniforms: {
          ...widget.uniforms,
          ..._controller.getUniforms(), // Include controller uniforms
        },
        performanceLevel: _performanceManager.performanceLevel,
      );
    }
  }

  @override
  void didUpdateWidget(ShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if controller is disposed
    if (_controller.isDisposed) {
      // Recreate controller if it was disposed
      _initializeController();
      _startContinuousAnimation();
    }

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
        widget.shader != oldWidget.shader ||
        widget.speed != oldWidget.speed ||
        widget.performanceLevel != oldWidget.performanceLevel) {
      _createPainter();
      _loadShaderAsync();
    }
  }

  int _getTargetFPS() {
    switch (_performanceManager.performanceLevel) {
      case PerformanceLevel.low:
        return 24; // Very low FPS for budget devices
      case PerformanceLevel.medium:
        return 30; // Medium FPS for mid-range devices
      case PerformanceLevel.high:
        return 60; // Full FPS for high-end devices
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if controller is disposed
    if (_controller.isDisposed) {
      return widget.child ?? const SizedBox.expand();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _painter,
          key: ValueKey<int>(_repaintKey),
          child: widget.child ?? const SizedBox.expand(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.stopPeriodicUpdates();
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
  void setCustomUniforms(FragmentShader shader, int index) {
    // Set custom uniforms from the uniforms map
    int currentIndex = index;

    for (final entry in uniforms.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is num) {
        shader.setFloat(currentIndex++, value.toDouble());
        debugPrint(
          'Setting uniform $key to number $value at index ${currentIndex - 1}',
        );
      } else if (value is Color) {
        shader.setFloat(currentIndex++, value.r);
        shader.setFloat(currentIndex++, value.g);
        shader.setFloat(currentIndex++, value.b);
        shader.setFloat(currentIndex++, value.a);
        debugPrint(
          'Setting uniform $key to color $value at indices ${currentIndex - 4} to ${currentIndex - 1}',
        );
      } else if (value is Offset) {
        shader.setFloat(currentIndex++, value.dx);
        shader.setFloat(currentIndex++, value.dy);
        debugPrint(
          'Setting uniform $key to offset $value at indices ${currentIndex - 2} to ${currentIndex - 1}',
        );
      } else if (value is Size) {
        shader.setFloat(currentIndex++, value.width);
        shader.setFloat(currentIndex++, value.height);
        debugPrint(
          'Setting uniform $key to size $value at indices ${currentIndex - 2} to ${currentIndex - 1}',
        );
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
