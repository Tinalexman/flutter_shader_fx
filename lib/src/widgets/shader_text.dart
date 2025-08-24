import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';

/// A text widget with shader effects for animated and stylized text rendering.
/// 
/// This widget provides text with shader-powered visual effects for creating
/// animated, glowing, or otherwise stylized text.
/// 
/// ## Usage
/// 
/// ```dart
/// // Glowing text
/// ShaderText.glow(
///   'Hello World',
///   glowColor: Colors.cyan,
///   glowIntensity: 0.8,
///   style: TextStyle(fontSize: 24),
/// )
/// 
/// // Custom shader text
/// ShaderText.custom(
///   'Animated Text',
///   shader: 'text_effect.frag',
///   uniforms: {'u_speed': 2.0},
///   style: TextStyle(fontSize: 20),
/// )
/// ```
class ShaderText extends StatefulWidget {
  /// Creates a shader text widget with a glow effect.
  /// 
  /// [text] is the text to display.
  /// [glowColor] is the color of the glow effect.
  /// [glowIntensity] controls the glow intensity (0.0 to 1.0).
  /// [style] is the text style to use.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderText.glow(
    this.text, {
    super.key,
    this.glowColor = Colors.cyan,
    this.glowIntensity = 0.8,
    this.style,
    this.performanceLevel,
  }) : effectType = ShaderTextEffectType.glow,
       shader = null,
       uniforms = const {};

  /// Creates a shader text widget with a custom shader effect.
  /// 
  /// [text] is the text to display.
  /// [shader] should be the path to the GLSL fragment shader file.
  /// [uniforms] are the uniform values to pass to the shader.
  /// [style] is the text style to use.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderText.custom(
    this.text, {
    super.key,
    required this.shader,
    this.uniforms = const {},
    this.style,
    this.performanceLevel,
  }) : effectType = null,
       glowColor = Colors.cyan,
       glowIntensity = 0.8;

  /// The text to display.
  final String text;

  /// The type of text effect to use.
  final ShaderTextEffectType? effectType;

  /// The path to the custom GLSL shader file.
  final String? shader;

  /// Uniform values to pass to the shader.
  final Map<String, dynamic> uniforms;

  /// Color for the glow effect.
  final Color glowColor;

  /// Glow intensity for glow effect (0.0 to 1.0).
  final double glowIntensity;

  /// The text style to use.
  final TextStyle? style;

  /// Performance level for the effect.
  final PerformanceLevel? performanceLevel;

  @override
  State<ShaderText> createState() => _ShaderTextState();
}

class _ShaderTextState extends State<ShaderText>
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
  }

  void _initializePerformanceManager() {
    _performanceManager = PerformanceManager(
      forcePerformanceLevel: widget.performanceLevel,
    );
  }

  void _createPainter() {
    if (widget.effectType == ShaderTextEffectType.glow) {
      _painter = _GlowTextPainter(
        text: widget.text,
        style: widget.style,
        glowColor: widget.glowColor,
        glowIntensity: widget.glowIntensity,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.shader != null) {
      _painter = _CustomTextShaderPainter(
        text: widget.text,
        style: widget.style,
        shaderPath: widget.shader!,
        uniforms: widget.uniforms,
        performanceLevel: _performanceManager.performanceLevel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _painter,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ShaderText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recreate painter if text, effect type, or shader changed
    if (widget.text != oldWidget.text ||
        widget.effectType != oldWidget.effectType ||
        widget.shader != oldWidget.shader ||
        widget.style != oldWidget.style) {
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

/// Glow effect painter for text.
class _GlowTextPainter extends BaseShaderPainter {
  _GlowTextPainter({
    required this.text,
    required this.style,
    required this.glowColor,
    required this.glowIntensity,
    required PerformanceLevel performanceLevel,
  }) : super(
    shaderPath: 'text_glow.frag',
    performanceLevel: performanceLevel,
  );

  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a simple glow effect
    _paintGlowText(canvas, size);
  }

  void _paintGlowText(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Calculate text position to center it
    final textSize = textPainter.size;
    final textOffset = Offset(
      (size.width - textSize.width) / 2,
      (size.height - textSize.height) / 2,
    );
    
    // Draw multiple glow layers
    final glowLayers = 5;
    for (int i = 0; i < glowLayers; i++) {
      final layerOpacity = glowIntensity * (1.0 - i / glowLayers) * 0.4;
      final layerBlur = (i + 1) * 2.0;
      
      final paint = Paint()
        ..color = glowColor.withOpacity(layerOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerBlur);
      
      textPainter.paint(canvas, textOffset);
    }
    
    // Draw the main text
    final mainPaint = Paint()
      ..color = style?.color ?? Colors.white;
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _GlowTextPainter oldDelegate) {
    return text != oldDelegate.text ||
           style != oldDelegate.style ||
           glowColor != oldDelegate.glowColor ||
           glowIntensity != oldDelegate.glowIntensity ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Custom shader painter for text effects.
class _CustomTextShaderPainter extends BaseShaderPainter {
  _CustomTextShaderPainter({
    required this.text,
    required this.style,
    required super.shaderPath,
    required super.uniforms,
    required super.performanceLevel,
  });

  final String text;
  final TextStyle? style;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a simple text rendering
    _paintCustomText(canvas, size);
  }

  void _paintCustomText(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Calculate text position to center it
    final textSize = textPainter.size;
    final textOffset = Offset(
      (size.width - textSize.width) / 2,
      (size.height - textSize.height) / 2,
    );
    
    // Draw the text with a simple effect
    final paint = Paint()
      ..color = style?.color ?? Colors.white;
    
    textPainter.paint(canvas, textOffset);
  }

  @override
  void setCustomUniforms(FragmentShader shader, int index) {
    // Set custom uniforms from the uniforms map
    for (final entry in uniforms.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is num) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting text uniform $key to number $value');
      } else if (value is Color) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting text uniform $key to color $value');
      } else if (value is Offset) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting text uniform $key to offset $value');
      } else if (value is Size) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting text uniform $key to size $value');
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CustomTextShaderPainter oldDelegate) {
    return text != oldDelegate.text ||
           style != oldDelegate.style ||
           uniforms != oldDelegate.uniforms ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Types of text shader effects available.
enum ShaderTextEffectType {
  /// Glow effect with colorful glow around text.
  glow,
  
  /// Animated text effect with flowing colors.
  animated,
  
  /// Holographic text effect with rainbow colors.
  holographic,
  
  /// Neon text effect with bright neon glow.
  neon,
} 