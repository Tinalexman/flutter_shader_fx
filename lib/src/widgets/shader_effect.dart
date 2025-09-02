import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';
import 'package:flutter_shader_fx/src/library/effect/distortion.dart';

/// A widget that applies a shader effect to the child widget.
class ShaderEffect extends StatefulWidget {
  const ShaderEffect.distortion({
    super.key,
    this.child,
    this.deviceDensity = 1.0,
    required this.performanceLevel,
    required this.intensity,
    required this.speed,
  }) : type = ShaderEffectType.distortion;

  /// The child widget to be painted by the shader effect.
  final Widget? child;

  /// The device density.
  final double deviceDensity;

  /// The type of shader effect to be used.
  final ShaderEffectType type;

  /// The performance level of the shader effect.
  final PerformanceLevel performanceLevel;

  /// The intensity of the shader effect.
  final double intensity;

  /// The speed of the shader effect.
  final double speed;

  @override
  State<ShaderEffect> createState() => _ShaderEffectState();
}

class _ShaderEffectState extends State<ShaderEffect> {
  late EffectController _controller;
  late PerformanceManager _performanceManager;
  BaseShaderPainter? _painter;

  final GlobalKey _repaintKey = GlobalKey();
  ui.Image? childImage;

  Offset _touchPosition = const Offset(0.5, 0.5);
  bool _isTouching = false;
  bool _isCapturing = false;
  bool _childImageReady = false;
  int _captureAttempts = 0;
  static const int _maxCaptureAttempts = 5;
  bool _showCaptureWidget = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializePerformanceManager();
    // DON'T start animation here - wait until after capture

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleCapture();
    });
  }

  void _scheduleCapture() {
    int frameCount = 0;
    void waitForFrames() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        frameCount++;
        if (frameCount < 3) {
          waitForFrames();
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _captureChild();
            }
          });
        }
      });
    }

    waitForFrames();
  }

  void _initializeController() {
    _controller = EffectController(autoDispose: false);
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _initializePerformanceManager() {
    _performanceManager = PerformanceManager(
      forcePerformanceLevel: widget.performanceLevel,
    );
  }

  void _startContinuousAnimation() {
    _controller.startPeriodicUpdates(
      frequency: (100 / _getTargetFPS()).toInt(),
      callback: (time) {
        if (mounted && !_controller.isDisposed) {
          // Controller will notify listeners automatically
        }
      },
    );
  }

  Future<void> _captureChild() async {
    if (_isCapturing || _captureAttempts >= _maxCaptureAttempts) {
      return;
    }

    _isCapturing = true;
    _captureAttempts++;

    try {
      final context = _repaintKey.currentContext;

      if (context == null || !context.mounted) {
        _scheduleRetryCapture();
        return;
      }

      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        _scheduleRetryCapture();
        return;
      }

      final RenderRepaintBoundary boundary = renderObject;

      if (!boundary.attached || !boundary.hasSize || boundary.size.isEmpty) {
        _scheduleRetryCapture();
        return;
      }

      if (boundary.debugNeedsPaint) {
        boundary.markNeedsPaint();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 16), () {
            if (mounted) {
              _scheduleRetryCapture();
            }
          });
        });
        return;
      }

      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );

      if (mounted && image.width > 0 && image.height > 0) {
        setState(() {
          childImage?.dispose();
          childImage = image;
          _childImageReady = true;
          _showCaptureWidget = false;
        });

        // Create painter with the captured image
        _createPainter();

        // Load shader
        await _loadShaderAsync();

        // ONLY start animation after everything is ready
        _startContinuousAnimation();
      } else {
        image.dispose();
        _scheduleRetryCapture();
      }
    } catch (e) {
      _scheduleRetryCapture();
    } finally {
      _isCapturing = false;
    }
  }

  void _scheduleRetryCapture() {
    _isCapturing = false;

    if (_captureAttempts < _maxCaptureAttempts && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _captureChild();
        }
      });
    } else {
      setState(() {
        _showCaptureWidget = false;
      });
    }
  }

  Offset getTouchPosition() => _touchPosition;

  void _updateTouchPosition(Offset position, Size size) {
    Offset normalizedPosition = Offset(
      position.dx / size.width,
      (position.dy / size.height),
    );

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

  void _resetTouch() {
    if (_isTouching) {
      setState(() {
        _isTouching = false;
      });
    }
  }

  void _createPainter() {
    _painter?.dispose();

    // Only create painter if we have a valid captured image
    if (widget.type == ShaderEffectType.distortion && childImage != null) {
      try {
        _painter = Distortion(
          intensity: widget.intensity,
          speed: widget.speed,
          image: childImage,
          touchPosition: getTouchPosition,
          deviceDensity: widget.deviceDensity,
        );
      } catch (e) {
        _painter = null;
      }
    } else {}
  }

  Future<void> _loadShaderAsync() async {
    if (_painter != null) {
      try {
        await _painter!.loadShader();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // If shader loading fails, dispose the painter
        _painter?.dispose();
        _painter = null;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void didUpdateWidget(ShaderEffect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.child != widget.child) {
      _captureAttempts = 0;
      _childImageReady = false;
      _showCaptureWidget = true;
      // Dispose old painter and image
      _painter?.dispose();
      _painter = null;
      childImage?.dispose();
      childImage = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleCapture();
      });
    }

    if (_controller.isDisposed) {
      _initializeController();
    }

    // Only recreate painter if parameters changed AND we have a valid image
    if ((oldWidget.type != widget.type ||
            oldWidget.intensity != widget.intensity ||
            oldWidget.speed != widget.speed) &&
        _childImageReady) {
      _createPainter();
      if (_painter != null) {
        _loadShaderAsync();
      }
    }

    if (_isTouching) {
      setState(() {});
    }
  }

  int _getTargetFPS() {
    switch (_performanceManager.performanceLevel) {
      case PerformanceLevel.low:
        return 24;
      case PerformanceLevel.medium:
        return 30;
      case PerformanceLevel.high:
        return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isDisposed) {
      return widget.child ?? const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return widget.child ?? const SizedBox();
        }

        return Stack(
          children: [
            // Capture widget - only show during capture phase
            if (_showCaptureWidget)
              Opacity(
                opacity: 0.01, // Very low opacity but not zero
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: widget.child,
                  ),
                ),
              ),

            // Shader effect overlay - only show when everything is ready
            if (_childImageReady && childImage != null && _painter != null)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Additional safety check before rendering
                  if (_painter == null || childImage == null) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: widget.child,
                    );
                  }

                  return GestureDetector(
                    onPanUpdate: (details) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final size = renderBox.size;
                      _updateTouchPosition(details.localPosition, size);
                    },
                    onPanEnd: (_) => _resetTouch(),
                    onTapDown: (details) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final size = renderBox.size;
                      _updateTouchPosition(details.localPosition, size);
                    },
                    onTapUp: (_) => _resetTouch(),
                    child: CustomPaint(
                      painter: _painter,
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              )
            else if (!_showCaptureWidget)
              // Fallback: show original child if shader isn't ready
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: widget.child,
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    childImage?.dispose();
    _controller.removeListener(() {});
    _controller.stopPeriodicUpdates();
    _controller.dispose();
    _painter?.dispose();
    super.dispose();
  }
}

enum ShaderEffectType { distortion }
