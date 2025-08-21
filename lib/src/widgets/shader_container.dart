import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';

/// A container widget with shader effects for wrapping other widgets.
/// 
/// This widget provides a container with shader-powered visual effects
/// that can wrap any child widget.
/// 
/// ## Usage
/// 
/// ```dart
/// // Glass morphism container
/// ShaderContainer.glassMorph(
///   child: Card(
///     child: Padding(
///       padding: EdgeInsets.all(16),
///       child: Text('Glass effect card'),
///     ),
///   ),
/// )
/// 
/// // Custom shader container
/// ShaderContainer.custom(
///   shader: 'my_effect.frag',
///   uniforms: {'u_intensity': 0.8},
///   child: Container(
///     padding: EdgeInsets.all(20),
///     child: Text('Custom effect'),
///   ),
/// )
/// ```
class ShaderContainer extends StatefulWidget {
  /// Creates a shader container with a glass morphism effect.
  /// 
  /// [blurRadius] controls the blur intensity.
  /// [borderRadius] is the border radius of the container.
  /// [borderColor] is the color of the border.
  /// [child] is the widget to display inside the container.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderContainer.glassMorph({
    super.key,
    this.blurRadius = 10.0,
    this.borderRadius = 12.0,
    this.borderColor = Colors.white,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderContainerEffectType.glassMorph,
       shader = null,
       uniforms = const {},
       glowColor = Colors.cyan,
       glowIntensity = 0.8;

  /// Creates a shader container with a neon glow effect.
  /// 
  /// [glowColor] is the color of the neon glow.
  /// [glowIntensity] controls the glow intensity (0.0 to 1.0).
  /// [borderRadius] is the border radius of the container.
  /// [child] is the widget to display inside the container.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderContainer.neonGlow({
    super.key,
    this.glowColor = Colors.cyan,
    this.glowIntensity = 0.8,
    this.borderRadius = 8.0,
    this.child,
    this.performanceLevel,
  }) : effectType = ShaderContainerEffectType.neonGlow,
       shader = null,
       uniforms = const {},
       blurRadius = 10.0,
       borderColor = Colors.white;

  /// Creates a shader container with a custom shader effect.
  /// 
  /// [shader] should be the path to the GLSL fragment shader file.
  /// [uniforms] are the uniform values to pass to the shader.
  /// [child] is the widget to display inside the container.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderContainer.custom({
    super.key,
    required this.shader,
    this.uniforms = const {},
    this.child,
    this.performanceLevel,
  }) : effectType = null,
       blurRadius = 10.0,
       borderRadius = 12.0,
       borderColor = Colors.white,
       glowColor = Colors.cyan,
       glowIntensity = 0.8;

  /// The type of container effect to use.
  final ShaderContainerEffectType? effectType;

  /// The path to the custom GLSL shader file.
  final String? shader;

  /// Uniform values to pass to the shader.
  final Map<String, dynamic> uniforms;

  /// Blur radius for glass morphism effect.
  final double blurRadius;

  /// Border radius for the container.
  final double borderRadius;

  /// Border color for glass morphism effect.
  final Color borderColor;

  /// Glow color for neon glow effect.
  final Color glowColor;

  /// Glow intensity for neon glow effect (0.0 to 1.0).
  final double glowIntensity;

  /// The widget to display inside the container.
  final Widget? child;

  /// Performance level for the effect.
  final PerformanceLevel? performanceLevel;

  @override
  State<ShaderContainer> createState() => _ShaderContainerState();
}

class _ShaderContainerState extends State<ShaderContainer>
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
    if (widget.effectType == ShaderContainerEffectType.glassMorph) {
      _painter = _GlassMorphPainter(
        blurRadius: widget.blurRadius,
        borderRadius: widget.borderRadius,
        borderColor: widget.borderColor,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.effectType == ShaderContainerEffectType.neonGlow) {
      _painter = _NeonGlowPainter(
        glowColor: widget.glowColor,
        glowIntensity: widget.glowIntensity,
        borderRadius: widget.borderRadius,
        performanceLevel: _performanceManager.performanceLevel,
      );
    } else if (widget.shader != null) {
      _painter = _CustomContainerShaderPainter(
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ShaderContainer oldWidget) {
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

/// Glass morphism effect painter for containers.
class _GlassMorphPainter extends BaseShaderPainter {
  _GlassMorphPainter({
    required this.blurRadius,
    required this.borderRadius,
    required this.borderColor,
    required PerformanceLevel performanceLevel,
  }) : super(
    shaderPath: 'glass_morph.frag',
    performanceLevel: performanceLevel,
  );

  final double blurRadius;
  final double borderRadius;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a simple glass effect
    _paintGlassEffect(canvas, size);
  }

  void _paintGlassEffect(Canvas canvas, Size size) {
    // Create a simple glass morphism effect
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    
    // Create a semi-transparent background
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(rect, paint);
    
    // Add a subtle border
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassMorphPainter oldDelegate) {
    return blurRadius != oldDelegate.blurRadius ||
           borderRadius != oldDelegate.borderRadius ||
           borderColor != oldDelegate.borderColor ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Neon glow effect painter for containers.
class _NeonGlowPainter extends BaseShaderPainter {
  _NeonGlowPainter({
    required this.glowColor,
    required this.glowIntensity,
    required this.borderRadius,
    required PerformanceLevel performanceLevel,
  }) : super(
    shaderPath: 'neon_glow.frag',
    performanceLevel: performanceLevel,
  );

  final Color glowColor;
  final double glowIntensity;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Since shader compilation is not yet available, we'll use a simple glow effect
    _paintGlowEffect(canvas, size);
  }

  void _paintGlowEffect(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    
    // Create multiple glow layers for a neon effect
    final glowLayers = 3;
    for (int i = 0; i < glowLayers; i++) {
      final layerOpacity = glowIntensity * (1.0 - i / glowLayers) * 0.3;
      final layerWidth = (i + 1) * 2.0;
      
      final paint = Paint()
        ..color = glowColor.withOpacity(layerOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = layerWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGlowPainter oldDelegate) {
    return glowColor != oldDelegate.glowColor ||
           glowIntensity != oldDelegate.glowIntensity ||
           borderRadius != oldDelegate.borderRadius ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Custom shader painter for container effects.
class _CustomContainerShaderPainter extends BaseShaderPainter {
  _CustomContainerShaderPainter({
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
        debugPrint('Setting container uniform $key to number $value');
      } else if (value is Color) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting container uniform $key to color $value');
      } else if (value is Offset) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting container uniform $key to offset $value');
      } else if (value is Size) {
        // Note: This will be implemented when FragmentShader API is available
        debugPrint('Setting container uniform $key to size $value');
      }
    }
  }
}

/// Types of container shader effects available.
enum ShaderContainerEffectType {
  /// Glass morphism effect with blur and transparency.
  glassMorph,
  
  /// Neon glow effect with colorful borders.
  neonGlow,
  
  /// Depth shadow effect for 3D illusion.
  depthShadow,
  
  /// Bokeh effect with depth of field blur.
  bokeh,
} 