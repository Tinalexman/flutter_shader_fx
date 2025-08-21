# Flutter Shader FX

A comprehensive Flutter package providing pre-built, performance-optimized shader effects for Flutter's Impeller renderer. Create stunning GPU-accelerated visual effects without requiring shader programming knowledge.

## Features

- 🎨 **22 Pre-built Effects**: Background, interactive, loading, and decorative effects
- ⚡ **Performance Optimized**: 60fps on flagship devices, 30fps on mid-range devices
- 📱 **Mobile First**: Built specifically for Flutter's Impeller renderer (Vulkan/Metal)
- 🚀 **Simple API**: Achieve stunning effects with minimal code
- 🔧 **Zero Shader Knowledge Required**: Widget-based API abstracts GLSL complexity
- 🌍 **Cross-Platform**: Same effects work identically across iOS, Android, Web, Desktop

## Quick Start

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_shader_fx: ^0.0.1
```

### Basic Usage

```dart
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

// Simple plasma background
ShaderBackground.plasma()

// Interactive ripple button
ShaderButton.ripple(
  onPressed: () => print('Button pressed!'),
  child: Text('Click me!'),
)

// Glass morphism container
ShaderContainer.glassMorph(
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Glass effect card'),
    ),
  ),
)

// Glowing text
ShaderText.glow(
  'Hello World',
  glowColor: Colors.cyan,
  glowIntensity: 0.8,
  style: TextStyle(fontSize: 24),
)
```

## Effect Categories

### Background Effects (8 total)
- **Plasma**: Organic flowing colors with customizable palette
- **Noise Field**: Perlin noise patterns with adjustable scale
- **Liquid Metal**: Reflective metallic surface with lighting
- **Fractal**: Mandelbrot/Julia variations with zoom capability
- **Particle Field**: Floating particles with physics simulation
- **Wave**: Sine wave interference with frequency control
- **Galaxy**: Spiral galaxy with twinkling stars
- **Aurora**: Northern lights with realistic color gradients

### Interactive Effects (6 total)
- **Ripple**: Touch ripple expanding from interaction point
- **Magnetic**: Visual elements attracted to cursor/finger
- **Glow Pulse**: Breathing glow effect on hover/press
- **Dissolve**: Particle dissolve transition between states
- **Holographic**: Rainbow hologram effect with viewing angle
- **Electric**: Lightning/electricity following touch path

### Loading Effects (4 total)
- **Liquid Progress**: Fluid filling animation tied to progress value
- **Geometric Morph**: Shape transformation indicating progress
- **Spiral Galaxy**: Rotating spiral with progress-based intensity
- **Quantum Dots**: Particle system loader with physics

### Decorative Effects (4 total)
- **Glass Morph**: iOS-style frosted glass with blur
- **Neon Glow**: Cyberpunk neon borders and highlights
- **Depth Shadow**: 3D depth illusion for flat surfaces
- **Bokeh**: Depth of field blur with customizable focus

## Advanced Usage

### Customized Effects

```dart
// Customized plasma background
ShaderBackground.plasma(
  colors: [Colors.purple, Colors.cyan],
  speed: 1.5,
  intensity: 0.8,
)

// Custom shader background
ShaderBackground.custom(
  shader: 'my_effect.frag',
  uniforms: {
    'u_color1': Colors.red,
    'u_color2': Colors.blue,
    'u_speed': 2.0,
  },
)
```

### Performance Optimization

```dart
// Force performance level for testing
ShaderBackground.plasma(
  performanceLevel: PerformanceLevel.low, // low, medium, high
)
```

### Custom Shaders

```dart
// Use your own GLSL shaders
ShaderBackground.custom(
  shader: 'my_custom_effect.frag',
  uniforms: {
    'u_time': 0.0,
    'u_resolution': [800.0, 600.0],
    'u_color1': Colors.purple,
  },
)
```

## Performance Requirements

- **60fps on flagship devices** (iPhone 14, Pixel 7, etc.)
- **30fps on mid-range devices** (3+ year old devices)
- **Graceful degradation** - automatically reduce quality if framerate drops
- **Memory conscious** - maximum 50MB additional RAM usage
- **Battery efficient** - effects should not cause significant battery drain

## Architecture

The package is built with a modular architecture:

```
flutter_shader_fx/
├── lib/
│   ├── src/
│   │   ├── effects/           # Effect categories
│   │   ├── core/              # Base classes and controllers
│   │   ├── widgets/           # Public widget APIs
│   │   └── utils/             # Helper utilities
│   └── flutter_shader_fx.dart # Main export file
├── shaders/                   # GLSL fragment shaders
├── example/                   # Comprehensive demo app
└── test/                      # Unit and widget tests
```

### Core Components

- **BaseShaderPainter**: All custom painters extend this class
- **EffectController**: Manages animations and state for all effects
- **PerformanceManager**: Handles device capability detection and optimization
- **ShaderLoader**: Manages shader asset loading and caching

## GLSL Shader Guidelines

When creating custom shaders:

- Use `precision mediump float` for mobile performance
- Maximum 64 iterations in any loop
- Comment complex math operations
- Use consistent uniform naming: `u_` prefix for all uniforms
- Optimize for mobile GPUs: avoid branches, prefer mix() over if/else

## Standard Uniforms

All effects support these standard uniforms (locations 0-5):

```glsl
uniform vec2 u_resolution;    // Screen resolution
uniform float u_time;         // Animation time
uniform vec2 u_touch;         // Touch/mouse position (normalized)
uniform float u_intensity;    // Effect intensity (0.0-1.0)
uniform vec4 u_color1;        // Primary color
uniform vec4 u_color2;        // Secondary color
```

## Error Handling

The package provides graceful error handling:

- **Shader compilation failures**: Fall back to solid color or gradient
- **Performance issues**: Automatically reduce quality settings
- **Device compatibility**: Detect capabilities and adjust accordingly
- **Memory constraints**: Implement shader caching and cleanup

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter test` to ensure everything works
4. Create a feature branch and submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

### Phase 1: Foundation ✅
- [x] Core architecture and base classes
- [x] First working effect (Plasma background)
- [x] Basic widget APIs

### Phase 2-4: Effect Implementation 🚧
- [ ] Background effects (8 total)
- [ ] Interactive effects (6 total)
- [ ] Loading effects (4 total)
- [ ] Decorative effects (4 total)

### Phase 5: Polish & Release 📋
- [ ] Comprehensive testing
- [ ] Documentation and examples
- [ ] Performance optimization
- [ ] Production release

## Support

- 📖 [Documentation](https://pub.dev/documentation/flutter_shader_fx)
- 🐛 [Issue Tracker](https://github.com/your-username/flutter_shader_fx/issues)
- 💬 [Discussions](https://github.com/your-username/flutter_shader_fx/discussions)

## Acknowledgments

- Flutter team for the Impeller renderer
- The GLSL shader community for inspiration
- All contributors and beta testers

---

**Note**: This package is currently in early development. The API may change as we refine the implementation and gather feedback from the community.
