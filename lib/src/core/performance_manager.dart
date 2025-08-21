import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages performance optimization for shader effects.
/// 
/// This class detects device capabilities and automatically adjusts
/// shader quality settings to ensure smooth performance across
/// different device tiers.
/// 
/// ## Usage
/// 
/// ```dart
/// final performanceManager = PerformanceManager();
/// 
/// // Get recommended performance level for current device
/// final level = performanceManager.getRecommendedPerformanceLevel();
/// 
/// // Check if device supports high-quality shaders
/// final supportsHighQuality = performanceManager.supportsHighQuality();
/// ```
class PerformanceManager {
  /// Creates a performance manager.
  /// 
  /// [forcePerformanceLevel] can be used to override automatic detection
  /// for testing purposes.
  PerformanceManager({PerformanceLevel? forcePerformanceLevel}) {
    if (forcePerformanceLevel != null) {
      _performanceLevel = forcePerformanceLevel;
    } else {
      _detectDeviceCapabilities();
    }
  }

  /// Current performance level for the device.
  PerformanceLevel _performanceLevel = PerformanceLevel.medium;

  /// Whether device capabilities have been detected.
  bool _capabilitiesDetected = false;

  /// Device memory in GB (estimated).
  double? _deviceMemory;

  /// Device CPU cores count.
  int? _cpuCores;

  /// Whether the device supports high-quality shaders.
  bool? _supportsHighQuality;

  /// Gets the current performance level.
  PerformanceLevel get performanceLevel => _performanceLevel;

  /// Gets the recommended performance level for the current device.
  PerformanceLevel getRecommendedPerformanceLevel() {
    if (!_capabilitiesDetected) {
      _detectDeviceCapabilities();
    }
    return _performanceLevel;
  }

  /// Checks if the device supports high-quality shader effects.
  bool supportsHighQuality() {
    if (!_capabilitiesDetected) {
      _detectDeviceCapabilities();
    }
    return _supportsHighQuality ?? false;
  }

  /// Gets the estimated device memory in GB.
  double? get deviceMemory => _deviceMemory;

  /// Gets the number of CPU cores.
  int? get cpuCores => _cpuCores;

  /// Detects device capabilities and sets appropriate performance level.
  void _detectDeviceCapabilities() {
    if (_capabilitiesDetected) return;

    try {
      _detectPlatformCapabilities();
      _detectHardwareCapabilities();
      _setPerformanceLevel();
    } catch (e) {
      // Fall back to medium performance level
      debugPrint('Failed to detect device capabilities: $e');
      _performanceLevel = PerformanceLevel.medium;
    }

    _capabilitiesDetected = true;
  }

  /// Detects platform-specific capabilities.
  void _detectPlatformCapabilities() {
    if (kIsWeb) {
      // Web has limited shader support
      _supportsHighQuality = false;
      _performanceLevel = PerformanceLevel.low;
    } else if (Platform.isAndroid) {
      _detectAndroidCapabilities();
    } else if (Platform.isIOS) {
      _detectIOSCapabilities();
    } else {
      // Desktop platforms generally support high quality
      _supportsHighQuality = true;
      _performanceLevel = PerformanceLevel.high;
    }
  }

  /// Detects Android-specific capabilities.
  void _detectAndroidCapabilities() {
    // Android capabilities vary widely by device
    // We'll use a conservative approach for now
    _supportsHighQuality = false;
    
    // Could be enhanced with device-specific detection
    // For now, assume mid-range capabilities
    _performanceLevel = PerformanceLevel.medium;
  }

  /// Detects iOS-specific capabilities.
  void _detectIOSCapabilities() {
    // iOS devices generally have good GPU performance
    // but we'll be conservative for battery life
    _supportsHighQuality = true;
    _performanceLevel = PerformanceLevel.medium;
  }

  /// Detects hardware capabilities.
  void _detectHardwareCapabilities() {
    // This would ideally use platform channels to get actual
    // device specifications. For now, we'll use conservative estimates.
    
    if (kIsWeb) {
      _deviceMemory = 4.0; // Conservative estimate for web
      _cpuCores = 4;
    } else if (Platform.isAndroid) {
      _deviceMemory = 4.0; // Conservative estimate
      _cpuCores = 4;
    } else if (Platform.isIOS) {
      _deviceMemory = 3.0; // Conservative estimate
      _cpuCores = 6;
    } else {
      _deviceMemory = 8.0; // Desktop estimate
      _cpuCores = 8;
    }
  }

  /// Sets the performance level based on detected capabilities.
  void _setPerformanceLevel() {
    if (_performanceLevel != PerformanceLevel.low) {
      // Check if we should downgrade based on capabilities
      if (_deviceMemory != null && _deviceMemory! < 2.0) {
        _performanceLevel = PerformanceLevel.low;
      } else if (_cpuCores != null && _cpuCores! < 4) {
        _performanceLevel = PerformanceLevel.low;
      }
    }
  }

  /// Gets quality settings for the current performance level.
  /// 
  /// Returns a map of quality settings that can be used to configure
  /// shader effects for optimal performance.
  Map<String, dynamic> getQualitySettings() {
    switch (_performanceLevel) {
      case PerformanceLevel.low:
        return {
          'maxIterations': 16,
          'textureQuality': 0.5,
          'shadowQuality': 0.25,
          'blurQuality': 0.5,
          'particleCount': 100,
          'animationFPS': 30,
        };
      case PerformanceLevel.medium:
        return {
          'maxIterations': 32,
          'textureQuality': 0.75,
          'shadowQuality': 0.5,
          'blurQuality': 0.75,
          'particleCount': 250,
          'animationFPS': 45,
        };
      case PerformanceLevel.high:
        return {
          'maxIterations': 64,
          'textureQuality': 1.0,
          'shadowQuality': 1.0,
          'blurQuality': 1.0,
          'particleCount': 500,
          'animationFPS': 60,
        };
    }
  }

  /// Checks if the current device can handle a specific effect complexity.
  /// 
  /// [complexity] should be a value between 0.0 and 1.0, where 1.0
  /// represents the most complex effects.
  bool canHandleComplexity(double complexity) {
    if (complexity <= 0.0) return true;
    if (complexity >= 1.0) return false;

    switch (_performanceLevel) {
      case PerformanceLevel.low:
        return complexity <= 0.3;
      case PerformanceLevel.medium:
        return complexity <= 0.7;
      case PerformanceLevel.high:
        return complexity <= 1.0;
    }
  }

  /// Gets recommended shader optimization settings.
  /// 
  /// These settings can be passed to shader compilers or used
  /// to adjust shader parameters for better performance.
  Map<String, dynamic> getShaderOptimizations() {
    switch (_performanceLevel) {
      case PerformanceLevel.low:
        return {
          'precision': 'mediump',
          'maxLoopIterations': 16,
          'disableBranches': true,
          'reducePrecision': true,
        };
      case PerformanceLevel.medium:
        return {
          'precision': 'mediump',
          'maxLoopIterations': 32,
          'disableBranches': false,
          'reducePrecision': false,
        };
      case PerformanceLevel.high:
        return {
          'precision': 'highp',
          'maxLoopIterations': 64,
          'disableBranches': false,
          'reducePrecision': false,
        };
    }
  }

  /// Forces a specific performance level (for testing).
  /// 
  /// This should only be used for testing purposes, not in production.
  void forcePerformanceLevel(PerformanceLevel level) {
    _performanceLevel = level;
    _capabilitiesDetected = true;
  }

  /// Resets the performance manager to re-detect capabilities.
  void reset() {
    _capabilitiesDetected = false;
    _deviceMemory = null;
    _cpuCores = null;
    _supportsHighQuality = null;
  }
}

/// Performance levels for shader effects.
/// 
/// These levels determine quality settings and optimization strategies
/// to ensure smooth performance across different device capabilities.
enum PerformanceLevel {
  /// Low performance mode for older devices.
  /// 
  /// Uses reduced quality settings and aggressive optimization.
  low,
  
  /// Medium performance mode for mid-range devices.
  /// 
  /// Balanced quality and performance settings.
  medium,
  
  /// High performance mode for flagship devices.
  /// 
  /// Maximum quality settings with minimal optimization.
  high,
} 