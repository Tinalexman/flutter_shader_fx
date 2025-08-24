import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/base_shader_painter.dart';
import '../core/effect_controller.dart';
import '../core/performance_manager.dart';

/// A widget that displays interactive shader effects with a child widget.
///
/// This widget provides easy-to-use interactive effects with a simple API.
/// It automatically handles performance optimization, lifecycle management,
/// and provides graceful fallbacks when shaders fail to load.
///
/// ## Usage
///
/// ```dart
/// // Simple interactive effect
/// ShaderInteractive(
///   painter: RippleEffect(
///     touchPosition: Offset(0.5, 0.5),
///     progress: 0.5,
///   ),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Interactive Content'),
///   ),
/// )
///
/// // With performance optimization
/// ShaderInteractive(
///   painter: MagneticEffect(
///     touchPosition: Offset(0.3, 0.7),
///     strength: 0.8,
///   ),
///   performanceLevel: PerformanceLevel.high,
///   child: Icon(Icons.favorite),
/// )
/// ```
class ShaderInteractive extends StatefulWidget {
  /// Creates a shader interactive widget.
  ///
  /// [painter] is the BaseShaderPainter to use for rendering the effect.
  /// [child] is the widget to display on top of the effect.
  /// [performanceLevel] determines the quality settings for the effect.
  const ShaderInteractive({
    super.key,
    required this.painter,
    this.child,
    this.performanceLevel,
  });

  /// The shader painter to use for rendering the effect.
  final BaseShaderPainter painter;

  /// The widget to display on top of the effect.
  final Widget? child;

  /// Performance level for the effect.
  final PerformanceLevel? performanceLevel;

  @override
  State<ShaderInteractive> createState() => _ShaderInteractiveState();
}

class _ShaderInteractiveState extends State<ShaderInteractive>
    with TickerProviderStateMixin {
  late EffectController _controller;
  late PerformanceManager _performanceManager;
  BaseShaderPainter? _painter;
  int _repaintKey = 0;

  @override
  void initState() {
    super.initState();
    _initializePerformanceManager();
    _initializeController();
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

    // Set initial values based on the painter's properties
    _updateControllerFromPainter();
  }

  void _initializePerformanceManager() {
    _performanceManager = PerformanceManager(
      forcePerformanceLevel: widget.performanceLevel,
    );
  }

  void _startContinuousAnimation() {
    // Start periodic updates for shader animation
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

    // Use the provided painter directly
    _painter = widget.painter;

    // Note: performanceLevel is final in BaseShaderPainter, so we can't modify it
    // The painter should be created with the correct performance level initially
  }

  void _updateControllerFromPainter() {
    // Set default intensity if the painter has an intensity property
    dynamic painter = widget.painter;
    if (painter.intensity != null) {
      _controller.setIntensity(painter.intensity);
    }

    // Set colors if available
    // if (painter.colors != null && painter.colors.isNotEmpty) {
    //   _controller.setColor1(painter.colors.first);
    //   if (painter.colors.length > 1) {
    //     _controller.setColor2(painter.colors[1]);
    //   }
    // }
  }

  @override
  void didUpdateWidget(ShaderInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if controller is disposed
    if (_controller.isDisposed) {
      // Recreate controller if it was disposed
      _initializeController();
      _startContinuousAnimation();
    }

    // Recreate painter if the painter instance changed
    if (widget.painter != oldWidget.painter) {
      _createPainter();
      _loadShaderAsync();
    }

    // Update performance level if changed
    if (widget.performanceLevel != oldWidget.performanceLevel) {
      _performanceManager = PerformanceManager(
        forcePerformanceLevel: widget.performanceLevel,
      );
      // Note: performanceLevel is final in BaseShaderPainter, so we can't modify it
      // The painter should be created with the correct performance level initially
    }

    // Update controller from new painter
    _updateControllerFromPainter();
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
