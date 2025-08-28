import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility functions for performance monitoring and optimization.
///
/// This class provides helper functions for monitoring performance,
/// detecting device capabilities, and optimizing shader effects.
class PerformanceUtils {
  /// Private constructor to prevent instantiation.
  PerformanceUtils._();

  /// Performance monitoring data.
  static final Map<String, PerformanceData> _performanceData = {};

  /// Frame rate monitoring.
  static final List<double> _frameRates = [];
  static const int _maxFrameRateSamples = 60;

  /// Last frame time for FPS calculation.
  static double? _lastFrameTime;

  /// Current frame rate.
  static double _currentFrameRate = 60.0;

  /// Gets the current frame rate.
  static double get currentFrameRate => _currentFrameRate;

  /// Gets the average frame rate over the last samples.
  static double get averageFrameRate {
    if (_frameRates.isEmpty) return 60.0;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }

  /// Gets the minimum frame rate over the last samples.
  static double get minimumFrameRate {
    if (_frameRates.isEmpty) return 60.0;
    return _frameRates.reduce((a, b) => a < b ? a : b);
  }

  /// Gets the maximum frame rate over the last samples.
  static double get maximumFrameRate {
    if (_frameRates.isEmpty) return 60.0;
    return _frameRates.reduce((a, b) => a > b ? a : b);
  }

  /// Updates the frame rate measurement.
  ///
  /// This should be called once per frame to maintain accurate FPS tracking.
  static void updateFrameRate() {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    if (_lastFrameTime != null) {
      final deltaTime = currentTime - _lastFrameTime!;
      if (deltaTime > 0.0) {
        final frameRate = 1.0 / deltaTime;
        _currentFrameRate = frameRate;

        _frameRates.add(frameRate);
        if (_frameRates.length > _maxFrameRateSamples) {
          _frameRates.removeAt(0);
        }
      }
    }

    _lastFrameTime = currentTime;
  }

  /// Starts performance monitoring for a specific operation.
  ///
  /// [operationName] is the name of the operation to monitor.
  /// Returns a unique identifier for the operation.
  static String startMonitoring(String operationName) {
    final id = '${operationName}_${DateTime.now().millisecondsSinceEpoch}';
    _performanceData[id] = PerformanceData(
      name: operationName,
      startTime: DateTime.now(),
    );
    return id;
  }

  /// Stops performance monitoring for an operation.
  ///
  /// [id] is the operation identifier returned by startMonitoring.
  /// Returns the duration of the operation in milliseconds.
  static double stopMonitoring(String id) {
    final data = _performanceData[id];
    if (data == null) return 0.0;

    data.endTime = DateTime.now();
    data.duration =
        data.endTime!.difference(data.startTime).inMicroseconds / 1000.0;

    return data.duration;
  }

  /// Gets performance data for a specific operation.
  ///
  /// [operationName] is the name of the operation.
  /// Returns a list of performance data entries.
  static List<PerformanceData> getPerformanceData(String operationName) {
    return _performanceData.values
        .where((data) => data.name == operationName)
        .toList();
  }

  /// Gets the average duration for a specific operation.
  ///
  /// [operationName] is the name of the operation.
  /// Returns the average duration in milliseconds.
  static double getAverageDuration(String operationName) {
    final data = getPerformanceData(operationName);
    if (data.isEmpty) return 0.0;

    final totalDuration = data.fold<double>(
      0.0,
      (sum, item) => sum + item.duration,
    );
    return totalDuration / data.length;
  }

  /// Clears all performance data.
  static void clearPerformanceData() {
    _performanceData.clear();
  }

  /// Detects if the device is experiencing performance issues.
  ///
  /// Returns true if the current frame rate is below the threshold.
  static bool isExperiencingPerformanceIssues({double threshold = 30.0}) {
    return _currentFrameRate < threshold;
  }

  /// Gets recommended quality settings based on current performance.
  ///
  /// Returns a map of quality settings to use.
  static Map<String, dynamic> getRecommendedQualitySettings() {
    final avgFPS = averageFrameRate;

    if (avgFPS >= 55.0) {
      return {
        'maxIterations': 64,
        'textureQuality': 1.0,
        'shadowQuality': 1.0,
        'blurQuality': 1.0,
        'particleCount': 500,
        'animationFPS': 60,
      };
    } else if (avgFPS >= 40.0) {
      return {
        'maxIterations': 32,
        'textureQuality': 0.75,
        'shadowQuality': 0.5,
        'blurQuality': 0.75,
        'particleCount': 250,
        'animationFPS': 45,
      };
    } else {
      return {
        'maxIterations': 16,
        'textureQuality': 0.5,
        'shadowQuality': 0.25,
        'blurQuality': 0.5,
        'particleCount': 100,
        'animationFPS': 30,
      };
    }
  }

  /// Estimates device memory usage.
  ///
  /// Returns estimated memory usage in MB.
  static double estimateMemoryUsage() {
    // This is a rough estimation based on common device characteristics
    // In a real implementation, you would use platform channels to get actual memory info

    if (kIsWeb) {
      return 50.0; // Conservative estimate for web
    } else if (Platform.isAndroid) {
      return 100.0; // Conservative estimate for Android
    } else if (Platform.isIOS) {
      return 80.0; // Conservative estimate for iOS
    } else {
      return 200.0; // Conservative estimate for desktop
    }
  }

  /// Checks if memory usage is high.
  ///
  /// [threshold] is the memory threshold in MB.
  /// Returns true if memory usage is above the threshold.
  static bool isMemoryUsageHigh({double threshold = 150.0}) {
    return estimateMemoryUsage() > threshold;
  }

  /// Gets performance statistics.
  ///
  /// Returns a map with performance information.
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'currentFrameRate': _currentFrameRate,
      'averageFrameRate': averageFrameRate,
      'minimumFrameRate': minimumFrameRate,
      'maximumFrameRate': maximumFrameRate,
      'frameRateSamples': _frameRates.length,
      'estimatedMemoryUsage': estimateMemoryUsage(),
      'isExperiencingPerformanceIssues': isExperiencingPerformanceIssues(),
      'isMemoryUsageHigh': isMemoryUsageHigh(),
      'performanceDataCount': _performanceData.length,
    };
  }

  /// Resets all performance monitoring data.
  static void reset() {
    _frameRates.clear();
    _performanceData.clear();
    _lastFrameTime = null;
    _currentFrameRate = 60.0;
  }

  /// Creates a performance monitor that automatically tracks frame rates.
  ///
  /// [onFrameRateUpdate] is called when the frame rate is updated.
  /// Returns a timer that can be cancelled to stop monitoring.
  static Timer createFrameRateMonitor(
    void Function(double frameRate)? onFrameRateUpdate,
  ) {
    return Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateFrameRate();
      onFrameRateUpdate?.call(_currentFrameRate);
    });
  }
}

/// Performance data for a specific operation.
class PerformanceData {
  /// Creates performance data.
  PerformanceData({required this.name, required this.startTime});

  /// The name of the operation.
  final String name;

  /// When the operation started.
  final DateTime startTime;

  /// When the operation ended.
  DateTime? endTime;

  /// Duration of the operation in milliseconds.
  double duration = 0.0;

  /// Whether the operation is still running.
  bool get isRunning => endTime == null;
}
