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
/// 
/// // Interactive ripple button
/// ShaderButton.ripple(
///   onPressed: () {},
///   child: Text('Click me!'),
/// )
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
/// - **Background Effects**: Plasma, Noise Field, Liquid Metal, Fractal, etc.
/// - **Interactive Effects**: Ripple, Magnetic, Glow Pulse, Dissolve, etc.
/// - **Loading Effects**: Liquid Progress, Geometric Morph, Spiral Galaxy, etc.
/// - **Decorative Effects**: Glass Morph, Neon Glow, Depth Shadow, Bokeh, etc.
library;

// Core exports
export 'src/core/base_shader_painter.dart';
export 'src/core/effect_controller.dart';
export 'src/core/performance_manager.dart';
export 'src/core/shader_loader.dart';

// Widget exports
export 'src/widgets/shader_background.dart';
export 'src/widgets/shader_button.dart';
export 'src/widgets/shader_container.dart';
export 'src/widgets/shader_text.dart';

// Effect exports
export 'src/effects/background/plasma_effect.dart';
export 'src/effects/background/noise_field_effect.dart';
export 'src/effects/background/liquid_metal_effect.dart';
export 'src/effects/background/fractal_effect.dart';
export 'src/effects/background/particle_field_effect.dart';
export 'src/effects/background/wave_effect.dart';
export 'src/effects/background/galaxy_effect.dart';
export 'src/effects/background/aurora_effect.dart';

export 'src/effects/interactive/ripple_effect.dart';
export 'src/effects/interactive/magnetic_effect.dart';
export 'src/effects/interactive/glow_pulse_effect.dart';
export 'src/effects/interactive/dissolve_effect.dart';
export 'src/effects/interactive/holographic_effect.dart';
export 'src/effects/interactive/electric_effect.dart';

export 'src/effects/loading/liquid_progress_effect.dart';
export 'src/effects/loading/geometric_morph_effect.dart';
export 'src/effects/loading/spiral_galaxy_effect.dart';
export 'src/effects/loading/quantum_dots_effect.dart';

export 'src/effects/decorative/glass_morph_effect.dart';
export 'src/effects/decorative/neon_glow_effect.dart';
export 'src/effects/decorative/depth_shadow_effect.dart';
export 'src/effects/decorative/bokeh_effect.dart';

// Utility exports
export 'src/utils/color_utils.dart';
export 'src/utils/math_utils.dart';
export 'src/utils/performance_utils.dart'; 