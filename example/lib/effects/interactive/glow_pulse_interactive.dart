import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class GlowPulseInteractive extends StatefulWidget {
  const GlowPulseInteractive({super.key});

  @override
  State<GlowPulseInteractive> createState() => _GlowPulseInteractiveState();
}

class _GlowPulseInteractiveState extends State<GlowPulseInteractive> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isActive = true),
          onTapUp: (_) => setState(() => _isActive = false),
          onTapCancel: () => setState(() => _isActive = false),
          child: ShaderInteractive(
            painter: GlowPulseEffect(
              isActive: _isActive,
              glowColor: Colors.cyan,
              pulseSpeed: 1.0,
              intensity: 0.8,
            ),
            child: const Center(
              child: Text(
                'Tap to activate glow pulse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
