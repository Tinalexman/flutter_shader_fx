import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Controller for managing shader effect animations and state.
/// 
/// This class provides a centralized way to control effect parameters,
/// animations, and performance settings for shader effects.
/// 
/// ## Usage
/// 
/// ```dart
/// final controller = EffectController();
/// 
/// // Start an animation
/// controller.animate(
///   duration: Duration(seconds: 2),
///   curve: Curves.easeInOut,
///   callback: (value) {
///     // Update effect parameters based on animation value
///   },
/// );
/// 
/// // Dispose when done
/// controller.dispose();
/// ```
class EffectController extends ChangeNotifier {
  /// Creates an effect controller.
  /// 
  /// [autoDispose] determines whether the controller automatically
  /// disposes itself when no listeners are attached.
  EffectController({this.autoDispose = true});

  /// Whether to automatically dispose the controller when no listeners are attached.
  final bool autoDispose;

  /// Current animation value (0.0 to 1.0).
  double _animationValue = 0.0;
  double get animationValue => _animationValue;

  /// Whether an animation is currently running.
  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  /// Current touch position in normalized coordinates (0.0 to 1.0).
  Offset _touchPosition = const Offset(0.5, 0.5);
  Offset get touchPosition => _touchPosition;

  /// Effect intensity (0.0 to 1.0).
  double _intensity = 1.0;
  double get intensity => _intensity;

  /// Primary color for the effect.
  Color _color1 = const Color(0xFF9C27B0);
  Color get color1 => _color1;

  /// Secondary color for the effect.
  Color _color2 = const Color(0xFF00BCD4);
  Color get color2 => _color2;

  /// Animation controller for managing animations.
  AnimationController? _animationController;

  /// Timer for periodic updates (e.g., for continuous effects).
  Timer? _updateTimer;

  /// Update frequency for continuous effects (in milliseconds).
  int _updateFrequency = 16; // ~60fps

  /// Sets the animation value.
  /// 
  /// [value] should be between 0.0 and 1.0.
  void setAnimationValue(double value) {
    _animationValue = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Sets the touch position.
  /// 
  /// [position] should be in normalized coordinates (0.0 to 1.0).
  void setTouchPosition(Offset position) {
    _touchPosition = Offset(
      position.dx.clamp(0.0, 1.0),
      position.dy.clamp(0.0, 1.0),
    );
    notifyListeners();
  }

  /// Sets the effect intensity.
  /// 
  /// [intensity] should be between 0.0 and 1.0.
  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Sets the primary color.
  void setColor1(Color color) {
    _color1 = color;
    notifyListeners();
  }

  /// Sets the secondary color.
  void setColor2(Color color) {
    _color2 = color;
    notifyListeners();
  }

  /// Sets both colors at once.
  void setColors(Color color1, Color color2) {
    _color1 = color1;
    _color2 = color2;
    notifyListeners();
  }

  /// Animates a parameter over time.
  /// 
  /// [duration] is the length of the animation.
  /// [curve] is the animation curve to use.
  /// [callback] is called with the current animation value (0.0 to 1.0).
  /// [repeat] determines whether the animation should repeat.
  /// [reverse] determines whether the animation should reverse on repeat.
  Future<void> animate({
    required Duration duration,
    Curve curve = Curves.linear,
    required void Function(double value) callback,
    bool repeat = false,
    bool reverse = false,
  }) async {
    _isAnimating = true;
    notifyListeners();

    _animationController?.dispose();
    _animationController = AnimationController(
      duration: duration,
      vsync: _createTickerProvider(),
    );

    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: curve,
    ));

    animation.addListener(() {
      final value = animation.value;
      _animationValue = value;
      callback(value);
      notifyListeners();
    });

    if (repeat) {
      if (reverse) {
        _animationController!.repeat(reverse: true);
      } else {
        _animationController!.repeat();
      }
    } else {
      await _animationController!.forward();
    }

    if (!repeat) {
      _isAnimating = false;
      notifyListeners();
    }
  }

  /// Stops the current animation.
  void stopAnimation() {
    _animationController?.stop();
    _isAnimating = false;
    notifyListeners();
  }

  /// Starts periodic updates for continuous effects.
  /// 
  /// [frequency] is the update frequency in milliseconds.
  /// [callback] is called on each update with the current time.
  void startPeriodicUpdates({
    int? frequency,
    required void Function(double time) callback,
  }) {
    _updateFrequency = frequency ?? _updateFrequency;
    
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      Duration(milliseconds: _updateFrequency),
      (timer) {
        final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
        callback(time);
        notifyListeners();
      },
    );
  }

  /// Stops periodic updates.
  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Creates a ticker provider for animations.
  /// 
  /// This is a simple implementation that provides vsync callbacks.
  /// In a real implementation, this would typically be provided by
  /// a StatefulWidget or other object that implements TickerProvider.
  TickerProvider _createTickerProvider() {
    return _SimpleTickerProvider();
  }

  /// Gets a map of current uniform values.
  /// 
  /// This is useful for passing to shader painters.
  Map<String, dynamic> getUniforms() {
    return {
      'u_animation': _animationValue,
      'u_touch': _touchPosition,
      'u_intensity': _intensity,
      'u_color1': _color1,
      'u_color2': _color2,
      'u_time': DateTime.now().millisecondsSinceEpoch / 1000.0,
    };
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    
    // Auto-dispose if no listeners and autoDispose is enabled
    if (autoDispose && !hasListeners) {
      dispose();
    }
  }
}

/// Simple ticker provider for animations.
/// 
/// This is a basic implementation that provides vsync callbacks.
/// In practice, you would typically use a StatefulWidget or other
/// object that implements TickerProvider.
class _SimpleTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'EffectController');
  }
} 