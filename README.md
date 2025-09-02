## Flutter Shader FX

A comprehensive Flutter package providing pre-built, performance‑optimized shader effects. Built for Impeller (Vulkan/Metal) with a simple, widget‑first API so developers can add stunning, GPU‑accelerated visuals without writing GLSL.

> Status: Early Release. Plasma and Glitch background effects are available. Additional effects will arrive in upcoming releases.

---

### Why Flutter Shader FX?
- **Performance first**: Mobile‑optimized shaders that target 60fps on flagship devices and 30fps on mid‑range devices
- **Simple API**: One‑line widgets for common effects, with sane defaults and clear customization
- **Impeller native**: Designed for Flutter’s modern renderer (Vulkan/Metal), not legacy Skia
- **Zero shader knowledge required**: Use widget APIs, or drop down to uniforms only when you need to
- **Cross‑platform consistency**: Identical effects across iOS, Android, Web, and Desktop

---

## Features

- Currently Available
  - **Background: Plasma** - Organic flowing colors with customizable palette
  - **Background: Glitch** - 5 different glitch types (Digital, Analog, Corruption, Tearing, Wave)

- Coming Soon (WIP)
  - Backgrounds: Noise Field, Liquid Metal, Fractal, Particle Field, Wave, Galaxy, Aurora
  - Interactive: Ripple, Magnetic, Glow Pulse, Dissolve, Holographic, Electric
  - Loading: Liquid Progress, Geometric Morph, Spiral Galaxy, Quantum Dots
  - Decorative: Glass Morph, Neon Glow, Depth Shadow, Bokeh
  - Core: Performance manager, shader loader, extended uniform presets, more widgets

- Other Capabilities (designed into the architecture)
  - Base painters, controllers, performance manager, shader loader, uniform management
  - Graceful degradation and fallbacks on shader failure

---

## Table of Contents
- Getting Started
- Quick Start
- Usage Examples
- Configuration & Uniforms
- Architecture
- Performance Guide
- Shaders & Conventions
- Error Handling & Fallbacks
- Testing & Quality
- Example App
- Roadmap
- Contributing
- FAQ
- License

---

## Getting Started

### Installation
Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_shader_fx: ^0.1.0
```

Then run:

```bash
flutter pub get
```

Ensure your Flutter app uses Impeller (enabled by default in recent stable releases). For older versions, enable Impeller with the appropriate flags for your platform.

---

## Quick Start

Add a plasma background in one line:

```dart
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

Widget build(BuildContext context) {
  return ShaderBackground.plasma();
}
```

---

## Usage Examples

### Background: Plasma (simple)
```dart
ShaderBackground.plasma()
```

### Background: Plasma (customized)
```dart
ShaderBackground.plasma(
  colors: const [Colors.purple, Colors.cyan],
  speed: 1.5,
  intensity: 0.8,
)
```

### Background: Glitch (simple)
```dart
ShaderBackground.glitch()
```

### Background: Glitch (customized)
```dart
ShaderBackground.glitch(
  colors: const [Colors.cyan, Colors.magenta],
  glitchType: GlitchType.analog,
  speed: 1.2,
  intensity: 0.9,
)
```

> Additional effects and interactive widgets coming soon. API previews may appear in docs.

---

## Configuration & Uniforms

All effects follow a standard uniform model with consistent names and locations:

- `u_resolution (vec2)` — Screen resolution
- `u_time (float)` — Seconds since start
- `u_touch (vec2)` — Normalized pointer position (0.0–1.0)
- `u_intensity (float)` — Global effect intensity (0.0–1.0)
- `u_color1 (vec4)` — Primary color
- `u_color2 (vec4)` — Secondary color
- Effect‑specific uniforms start from location 6

Common widget parameters map to these uniforms and are documented in dartdoc for each public class.

---

## Architecture

Project structure:

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

Core components:
- `BaseShaderPainter` — Base class for all custom painters
- `EffectController` — Manages animation and state for effects
- `PerformanceManager` — Detects device capabilities, adjusts quality
- `ShaderLoader` — Loads and caches shader assets

Design principles:
- Composition over inheritance for combining effects
- Immutable public objects where feasible (`@immutable`)
- Simple, consistent widget APIs with sensible defaults

---

## Performance Guide

- Target **60fps** on flagships and **30fps** on mid‑range devices
- Use `precision mediump float` in shaders for mobile performance
- Prefer `mix()`, `step()`, `smoothstep()` over branching
- Limit loops to **≤ 64 iterations** (ray marching/particles)
- Automatically degrade quality when frame times spike
- Keep GPU workload predictable and avoid divergent branches
- Memory budget: additional RAM usage ≤ 50MB
- Battery: avoid excessive overdraw and long‑running heavy effects on static screens

Tips:
- Keep `intensity` within reasonable ranges for mobile
- Avoid stacking multiple heavy effects on the same scene tree
- Test on real devices; shader performance varies by GPU/driver

---

## Shaders & Conventions

GLSL guidelines for this project:
- `precision mediump float` for all fragment shaders unless highp is required
- Consistent uniform naming with `u_` prefix
- Comment non‑trivial math and utility functions
- Avoid complex branching; use `mix()`/`smoothstep()` patterns
- Keep shader code modular and reusable across effects

Shader location: `shaders/`

---

## Error Handling & Fallbacks

- Shader compilation failure → fallback to a solid color or gradient
- Performance degradation detected → reduce quality parameters automatically
- Device capability mismatch → adjust accuracy or disable problematic features
- Shader cache is maintained and cleaned up to honor memory budgets

All public widgets fail gracefully and never crash the app due to shader issues.

---

## Testing & Quality

- Unit tests for all widget classes and utilities (`test/`)
- Golden tests where feasible for visual consistency
- Performance benchmarks across device tiers
- Integration tests in the example app
- Manual testing matrix across iOS/Android/Web/Desktop

Run tests:

```bash
flutter test
```

---

## Example App

A comprehensive demo is available under `example/`. The demo showcases both Plasma and Glitch effects with interactive examples and customization options.

Run the example:

```bash
cd example
flutter run
```

---

## Roadmap

Phase 1: Foundation ✅
- Core architecture and first shipping effects (Plasma and Glitch backgrounds)

Phase 2–4: Effects
- Implement background effects first, then interactive, loading, decorative
- Continuous optimization and API consistency improvements

Phase 5: Polish & Release
- Docs, examples, performance tuning, cross‑platform QA

Community Goals
- Pub points excellence, strong documentation, and adoption in popular apps

---

## Contributing

Contributions are welcome! Please:
- Follow the Dart style guide (80‑char line limit where practical)
- Use descriptive names (e.g., `plasmaIntensity`)
- Document all public APIs with dartdoc and examples
- Prefer composition; avoid deep inheritance chains
- Include tests (unit, golden where possible)
- Consider battery and thermal impacts when adding heavy effects

Open pull requests with a clear description, screenshots/gifs where applicable, and performance notes.

---

## FAQ

- Can I use these effects without knowing GLSL?
  Yes. The widget API abstracts shader details. For advanced use, you can pass uniforms directly.

- Does this work with Skia?
  It targets Impeller first. Some effects may work under Skia, but performance and consistency are not guaranteed.

- How do I keep 60fps?
  Use mediump precision, avoid stacking heavy effects, and let the performance manager adapt quality.

- Is Web supported?
  Yes, with consistent results. Test on target browsers/GPUs; performance varies.

---

## License

This project is licensed under the MIT License. See `LICENSE` for details. 