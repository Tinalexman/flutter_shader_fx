import 'dart:async';
import 'package:flutter/material.dart';

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
  EffectController({this.autoDispose = false}); // Changed default to false

  /// Whether to automatically dispose the controller when no listeners are attached.
  final bool autoDispose;

  /// Whether the controller has been disposed.
  bool _disposed = false;
  bool get isDisposed => _disposed;

  /// Current animation value (0.0 to 1.0).
  double _animationValue = 0.0;
  double get animationValue => _animationValue;

  /// Whether an animation is currently running.
  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

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
    if (_disposed) return;
    _animationValue = value.clamp(0.0, 1.0);
    _safeNotifyListeners();
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
    required TickerProvider vsync,
    Curve curve = Curves.linear,
    required void Function(double value) callback,
    bool repeat = false,
    bool reverse = false,
  }) async {
    if (_disposed) return;

    _isAnimating = true;
    _safeNotifyListeners();

    _animationController?.dispose();
    _animationController = AnimationController(
      duration: duration,
      vsync: vsync, // Use provided vsync instead of creating our own
    );

    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController!, curve: curve));

    animation.addListener(() {
      if (_disposed) return;
      final value = animation.value;
      _animationValue = value;
      callback(value);
      _safeNotifyListeners();
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

    if (!repeat && !_disposed) {
      _isAnimating = false;
      _safeNotifyListeners();
    }
  }

  /// Stops the current animation.
  void stopAnimation() {
    if (_disposed) return;
    _animationController?.stop();
    _isAnimating = false;
    _safeNotifyListeners();
  }

  /// Starts periodic updates for continuous effects.
  ///
  /// [frequency] is the update frequency in milliseconds.
  /// [callback] is called on each update with the current time.
  void startPeriodicUpdates({
    int? frequency,
    required void Function(double time) callback,
  }) {
    if (_disposed) return;

    _updateFrequency = frequency ?? _updateFrequency;

    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(Duration(milliseconds: _updateFrequency), (
      timer,
    ) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      callback(time);
      _safeNotifyListeners();
    });
  }

  /// Stops periodic updates.
  void stopPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }


  /// Safely notifies listeners only if not disposed and has listeners.
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;
    _animationController?.dispose();
    _animationController = null;
    _updateTimer?.cancel();
    _updateTimer = null;

    super.dispose();
  }

  @override
  void notifyListeners() {
    _safeNotifyListeners();
  }
}
