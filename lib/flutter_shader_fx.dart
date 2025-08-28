/// Flutter Shader FX - A comprehensive shader effects library for Flutter
/// 
/// This package provides developers with easy-to-use, GPU-accelerated visual 
/// effects without requiring shader programming knowledge. Built specifically 
/// for Flutter's Impeller renderer with mobile-first performance optimization.
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:flutter_shader_fx/flutter_shader_fx.dart';
/// 
/// // Simple plasma background
/// ShaderBackground.plasma()
/// ```
/// 
/// ## Performance
/// 
/// All effects are optimized for:
/// - 60fps on flagship devices (iPhone 14, Pixel 7, etc.)
/// - 30fps on mid-range devices (3+ year old devices)
/// - Graceful degradation when performance drops
/// - Maximum 50MB additional RAM usage
/// 
/// ## Effect Categories
/// 
/// - **Background Effects**: Plasma etc.
library;

// Core exports
export 'src/core/base_shader_painter.dart';
export 'src/core/effect_controller.dart';
export 'src/core/performance_manager.dart';

// Widget exports
export 'src/widgets/shader_background.dart';


// Effect exports
export 'src/effects/background/plasma_effect.dart';

// Utility exports
export 'src/utils/color_utils.dart';
export 'src/utils/math_utils.dart';
export 'src/utils/performance_utils.dart'; 