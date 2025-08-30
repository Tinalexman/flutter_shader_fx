import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

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
  /// Creates a shader background with a plasma effect.
  ///
  /// [colors] is the colors of the plasma effect.
  /// [speed] is the speed of the animation.
  /// [intensity] is the intensity of the effect.
  /// [child] is the widget to display on top of the background.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.plasma({
    super.key,
    this.colors = const [Color(0xFF9C27B0), Color(0xFF00BCD4)],
    this.speed = 1.0,
    this.child,
    this.intensity = 1.0,
    this.performanceLevel,
    this.size = const Size(100, 100),
  }) : uniforms = const {},
       effect = ShaderEffect.plasma,
       glitchType = null;

  /// Creates a shader background with a glitch effect.
  ///
  /// [colors] is the colors of the glitch effect.
  /// [speed] is the speed of the animation.
  /// [intensity] is the intensity of the effect.
  /// [child] is the widget to display on top of the background.
  /// [glitchType] is the type of glitch effect.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderBackground.glitch({
    super.key,
    this.colors = const [Colors.white],
    this.speed = 1.0,
    this.child,
    this.intensity = 1.0,
    this.performanceLevel,
    this.glitchType = GlitchType.corruption,
    this.size = const Size(100, 100),
  }) : uniforms = const {},
       effect = ShaderEffect.glitch;

  /// The size of the background.
  final Size size;

  /// The type of shader to be used;
  final ShaderEffect effect;

  /// The type of glitch effect.
  final GlitchType? glitchType;

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
  int _repaintKey = 0; // Key to force repaints

  // Touch position tracking
  Offset _touchPosition = const Offset(0.5, 0.5); // Default to center
  bool _isTouching = false;

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

  /// Gets the current touch position in normalized coordinates (0.0 to 1.0).
  Offset getTouchPosition() => _touchPosition;

  /// Updates the touch position and triggers a repaint.
  void _updateTouchPosition(Offset position, Size size) {
    // Convert to normalized coordinates (0.0 to 1.0) with Y-axis flip
    Offset normalizedPosition = Offset(
      position.dx / size.width,
      (position.dy / size.height),
    );

    // Clamp to valid range
    Offset clampedPosition = Offset(
      normalizedPosition.dx.clamp(0.0, 1.0),
      normalizedPosition.dy.clamp(0.0, 1.0),
    );

    if (_touchPosition != clampedPosition) {
      setState(() {
        _touchPosition = clampedPosition;
        _isTouching = true;
      });
    }
  }

  /// Resets touch state when touch ends.
  void _resetTouch() {
    if (_isTouching) {
      setState(() {
        _isTouching = false;
      });
    }
  }

  void _createPainter() {
    _painter?.dispose();

    if (widget.effect == ShaderEffect.plasma) {
      _painter = PlasmaEffect(
        colors: widget.colors,
        intensity: widget.intensity,
        performanceLevel: widget.performanceLevel,
        speed: widget.speed,
        touchPosition: getTouchPosition,
      );
    }
    if (widget.effect == ShaderEffect.glitch) {
      _painter = GlitchEffect(
        colors: widget.colors,
        intensity: widget.intensity,
        glitchType: widget.glitchType ?? GlitchType.corruption,
        performanceLevel: widget.performanceLevel,
        speed: widget.speed,
        touchPosition: getTouchPosition,
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

    int oldWidgetColorsHashCode = oldWidget.colors.hashCode;
    int newWidgetColorsHashCode = widget.colors.hashCode;

    // Recreate painter if effect type or shader changed
    if (widget.effect != oldWidget.effect ||
        widget.speed != oldWidget.speed ||
        widget.intensity != oldWidget.intensity ||
        oldWidgetColorsHashCode != newWidgetColorsHashCode ||
        widget.performanceLevel != oldWidget.performanceLevel ||
        widget.glitchType != oldWidget.glitchType) {
      _createPainter();
      _loadShaderAsync();
    }

    // Force repaint when touch position changes (for interactive effects)
    if (_isTouching) {
      setState(() => _repaintKey++);
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
        return GestureDetector(
          onPanUpdate: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final size = renderBox.size;
            _updateTouchPosition(details.localPosition, size);
          },
          onPanEnd: (_) => _resetTouch(),
          onTapDown: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final size = renderBox.size;
            _updateTouchPosition(details.localPosition, size);
          },
          onTapUp: (_) => _resetTouch(),
          child: SizedBox.fromSize(
            size: widget.size,
            child: CustomPaint(
              painter: _painter,
              key: ValueKey<int>(_repaintKey),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
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

enum ShaderEffect { plasma, glitch }
