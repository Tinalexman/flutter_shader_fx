import 'package:flutter/material.dart';
import 'background/plasma_background.dart';
import 'background/noise_field_background.dart';
import 'background/liquid_metal_background.dart';
import 'background/fractal_background.dart';
import 'background/particle_field_background.dart';
import 'background/wave_background.dart';
import 'background/galaxy_background.dart';
import 'background/aurora_background.dart';
import 'interactive/ripple_interactive.dart';
import 'interactive/magnetic_interactive.dart';
import 'interactive/glow_pulse_interactive.dart';
import 'interactive/dissolve_interactive.dart';
import 'interactive/holographic_interactive.dart';
import 'interactive/electric_interactive.dart';
import 'loading/liquid_progress_loading.dart';
import 'loading/geometric_morph_loading.dart';
import 'loading/spiral_galaxy_loading.dart';
import 'loading/quantum_dots_loading.dart';
import 'decorative/glass_morph_decorative.dart';
import 'decorative/neon_glow_decorative.dart';
import 'decorative/depth_shadow_decorative.dart';
import 'decorative/bokeh_decorative.dart';

class Effects extends StatefulWidget {
  const Effects({super.key});

  @override
  State<Effects> createState() => _EffectsState();
}

class _EffectsState extends State<Effects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🎨 Flutter Shader FX",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCategorySection(
                title: "🌌 Background Effects",
                subtitle: "Stunning visual backgrounds for your app",
                effects: _backgroundEffects,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                title: "🎮 Interactive Effects",
                subtitle: "Engaging touch and hover interactions",
                effects: _interactiveEffects,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                title: "⏳ Loading Effects",
                subtitle: "Beautiful progress indicators and loaders",
                effects: _loadingEffects,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                title: "✨ Decorative Effects",
                subtitle: "Elegant visual enhancements and styling",
                effects: _decorativeEffects,
              ),
              const SizedBox(height: 32),
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            "22 Amazing Shader Effects",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Explore our collection of GPU-accelerated visual effects",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required String subtitle,
    required List<EffectItem> effects,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF313131),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: effects.length,
            itemBuilder: (context, index) {
              final effect = effects[index];
              return _buildEffectCard(effect);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEffectCard(EffectItem effect) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => effect.page),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(12),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              effect.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              effect.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              effect.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rocket_launch,
            size: 32,
            color: Colors.white,
          ),
          SizedBox(height: 12),
          Text(
            "Ready to create amazing experiences?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Tap any effect above to see it in action!",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Background Effects
  static final List<EffectItem> _backgroundEffects = [
    EffectItem(
      name: "Plasma",
      description: "Organic flowing colors",
      icon: "🌊",
      page: const PlasmaBackground(),
    ),
    EffectItem(
      name: "Noise Field",
      description: "Perlin noise patterns",
      icon: "🌫️",
      page: const NoiseFieldBackground(),
    ),
    EffectItem(
      name: "Liquid Metal",
      description: "Reflective metallic surface",
      icon: "🔮",
      page: const LiquidMetalBackground(),
    ),
    EffectItem(
      name: "Fractal",
      description: "Mandelbrot/Julia sets",
      icon: "🌀",
      page: const FractalBackground(),
    ),
    EffectItem(
      name: "Particle Field",
      description: "Floating particles",
      icon: "✨",
      page: const ParticleFieldBackground(),
    ),
    EffectItem(
      name: "Wave",
      description: "Sine wave interference",
      icon: "🌊",
      page: const WaveBackground(),
    ),
    EffectItem(
      name: "Galaxy",
      description: "Spiral galaxy with stars",
      icon: "🌌",
      page: const GalaxyBackground(),
    ),
    EffectItem(
      name: "Aurora",
      description: "Northern lights effect",
      icon: "🌌",
      page: const AuroraBackground(),
    ),
  ];

  // Interactive Effects
  static final List<EffectItem> _interactiveEffects = [
    EffectItem(
      name: "Ripple",
      description: "Touch ripple expansion",
      icon: "💧",
      page: const RippleInteractive(),
    ),
    EffectItem(
      name: "Magnetic",
      description: "Attraction to cursor",
      icon: "🧲",
      page: const MagneticInteractive(),
    ),
    EffectItem(
      name: "Glow Pulse",
      description: "Breathing glow effect",
      icon: "💫",
      page: const GlowPulseInteractive(),
    ),
    EffectItem(
      name: "Dissolve",
      description: "Particle dissolve",
      icon: "💨",
      page: const DissolveInteractive(),
    ),
    EffectItem(
      name: "Holographic",
      description: "Rainbow hologram",
      icon: "🌈",
      page: const HolographicInteractive(),
    ),
    EffectItem(
      name: "Electric",
      description: "Lightning effects",
      icon: "⚡",
      page: const ElectricInteractive(),
    ),
  ];

  // Loading Effects
  static final List<EffectItem> _loadingEffects = [
    EffectItem(
      name: "Liquid Progress",
      description: "Fluid filling animation",
      icon: "🌊",
      page: const LiquidProgressLoading(),
    ),
    EffectItem(
      name: "Geometric Morph",
      description: "Shape transformation",
      icon: "🔷",
      page: const GeometricMorphLoading(),
    ),
    EffectItem(
      name: "Spiral Galaxy",
      description: "Rotating spiral",
      icon: "🌌",
      page: const SpiralGalaxyLoading(),
    ),
    EffectItem(
      name: "Quantum Dots",
      description: "Particle system loader",
      icon: "🔬",
      page: const QuantumDotsLoading(),
    ),
  ];

  // Decorative Effects
  static final List<EffectItem> _decorativeEffects = [
    EffectItem(
      name: "Glass Morph",
      description: "Frosted glass effect",
      icon: "🥃",
      page: const GlassMorphDecorative(),
    ),
    EffectItem(
      name: "Neon Glow",
      description: "Cyberpunk neon",
      icon: "💎",
      page: const NeonGlowDecorative(),
    ),
    EffectItem(
      name: "Depth Shadow",
      description: "3D depth illusion",
      icon: "🏔️",
      page: const DepthShadowDecorative(),
    ),
    EffectItem(
      name: "Bokeh",
      description: "Depth of field blur",
      icon: "📸",
      page: const BokehDecorative(),
    ),
  ];
}

class EffectItem {
  final String name;
  final String description;
  final String icon;
  final Widget page;

  const EffectItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.page,
  });
}
