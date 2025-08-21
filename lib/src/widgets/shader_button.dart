import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';

/// A button widget with shader effects for interactive visual feedback.
/// 
/// This widget provides easy-to-use button effects with shader-powered
/// visual feedback for touch interactions.
/// 
/// ## Usage
/// 
/// ```dart
/// // Simple ripple button
/// ShaderButton.ripple(
///   onPressed: () => print('Button pressed!'),
///   child: Text('Click me!'),
/// )
/// 
/// // Customized ripple button
/// ShaderButton.ripple(
///   onPressed: () {},
///   rippleColor: Colors.blue,
///   rippleDuration: Duration(milliseconds: 800),
///   child: Icon(Icons.favorite),
/// )
/// ```
class ShaderButton extends StatefulWidget {
  /// Creates a shader button with a ripple effect.
  /// 
  /// [onPressed] is the callback when the button is pressed.
  /// [rippleColor] is the color of the ripple effect.
  /// [rippleDuration] is the duration of the ripple animation.
  /// [child] is the widget to display inside the button.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderButton.ripple({
    super.key,
    required this.onPressed,
    this.rippleColor = Colors.white,
    this.rippleDuration = const Duration(milliseconds: 600),
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderButtonEffectType.ripple,
       shader = null,
       uniforms = const {};

  /// Creates a shader button with a custom shader effect.
  /// 
  /// [onPressed] is the callback when the button is pressed.
  /// [shader] should be the path to the GLSL fragment shader file.
  /// [uniforms] are the uniform values to pass to the shader.
  /// [child] is the widget to display inside the button.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderButton.custom({
    super.key,
    required this.onPressed,
    required this.shader,
    this.uniforms = const {},
    this.child,
    this.performanceLevel,
  }) : effectType = null,
       rippleColor = Colors.white,
       rippleDuration = const Duration(milliseconds: 600);

  /// The type of button effect to use.
  final ShaderButtonEffectType? effectType;

  /// The path to the custom GLSL shader file.
  final String? shader;

  /// Uniform values to pass to the shader.
  final Map<String, dynamic> uniforms;

  /// Color for the ripple effect.
  final Color rippleColor;

  /// Duration of the ripple animation.
  final Duration rippleDuration;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// The widget to display inside the button.
  final Widget? child;

  /// Performance level for the effect.
  final PerformanceLevel? performanceLevel;

  @override
  State<ShaderButton> createState() => _ShaderButtonState();
}

class _ShaderButtonState extends State<ShaderButton>
    with TickerProviderStateMixin {
  late EffectController _controller;
  late PerformanceManager _performanceManager;
  BaseShaderPainter? _painter;
  Offset? _lastTouchPosition;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializePerformanceManager();
    _createPainter();
  }

  void _initializeController() {
    _controller = EffectController();
  }

  void _initializePerformanceManager() {
    _performanceManager = PerformanceManager(
      forcePerformanceLevel: widget.performanceLevel,
    );
  }

  void _createPainter() {
    if (widget.effectType == ShaderButtonEffectType.ripple) {
      _painter = _RippleEffectPainter(
        color: widget.rippleColor,
        duration: widget.rippleDuration,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.shader != null) {
      _painter = _CustomButtonShaderPainter(
        shaderPath: widget.shader!,
        uniforms: widget.uniforms,
        performanceLevel: _performanceManager.performanceLevel,
      );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    final position = details.localPosition;
    final size = context.size;
    
    if (size != null) {
      // Convert to normalized coordinates (0.0 to 1.0)
      final normalizedPosition = Offset(
        position.dx / size.width,
        position.dy / size.height,
      );
      
      _lastTouchPosition = normalizedPosition;
      _controller.setTouchPosition(normalizedPosition);
      
      // Start ripple animation
      if (widget.effectType == ShaderButtonEffectType.ripple) {
        _startRippleAnimation();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    // Handle tap up if needed
  }

  void _handleTapCancel() {
    // Handle tap cancel if needed
  }

  void _startRippleAnimation() {
    _controller.animate(
      duration: widget.rippleDuration,
      curve: Curves.easeOut,
      callback: (value) {
        // Animation callback - could be used for additional effects
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _painter,
            child: widget.child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  @override
  void didUpdateWidget(ShaderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recreate painter if effect type or shader changed
    if (widget.effectType != oldWidget.effectType ||
        widget.shader != oldWidget.shader) {
      _createPainter();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _painter?.dispose();
    super.dispose();
  }
}

/// Ripple effect painter for button interactions.
class _RippleEffectPainter extends BaseShaderPainter {
  _RippleEffectPainter({
    required this.color,
    required this.duration,
    required PerformanceLevel performanceLevel,
  }) : super(
    shaderPath: 'ripple.frag',
    performanceLevel: performanceLevel,
  );

  final Color color;
  final Duration duration;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a simple ripple effect
    _paintRippleEffect(canvas, size);
  }

  void _paintRippleEffect(Canvas canvas, Size size) {
    // Create a simple ripple effect using circles
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;
    
    // Create multiple ripple rings
    final ringCount = 3;
    for (int i = 0; i < ringCount; i++) {
      final progress = (i / ringCount);
      final radius = maxRadius * progress;
      final opacity = (1.0 - progress) * 0.3;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RippleEffectPainter oldDelegate) {
    return color != oldDelegate.color ||
           duration != oldDelegate.duration ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Custom shader painter for button effects.
class _CustomButtonShaderPainter extends BaseShaderPainter {
  _CustomButtonShaderPainter({
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
        debugPrint('Setting button uniform $key to number $value');
      } else if (value is Color) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting button uniform $key to color $value');
      } else if (value is Offset) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting button uniform $key to offset $value');
      } else if (value is Size) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting button uniform $key to size $value');
      }
    }
  }
}

/// Types of button shader effects available.
enum ShaderButtonEffectType {
  /// Ripple effect that expands from touch point.
  ripple,
  
  /// Magnetic effect that attracts visual elements to cursor.
  magnetic,
  
  /// Glow pulse effect with breathing glow on hover/press.
  glowPulse,
  
  /// Dissolve effect with particle dissolve transition.
  dissolve,
  
  /// Holographic effect with rainbow hologram.
  holographic,
  
  /// Electric effect with lightning following touch path.
  electric,
} 