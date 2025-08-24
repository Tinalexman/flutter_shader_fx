import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class NeonGlowDecorative extends StatefulWidget {
  const NeonGlowDecorative({super.key});

  @override
  State<NeonGlowDecorative> createState() => _NeonGlowDecorativeState();
}

class _NeonGlowDecorativeState extends State<NeonGlowDecorative> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neon Glow Decorative'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 200,
            height: 100,
            child: CustomPaint(
              painter: NeonGlowEffect(
                neonColor: Colors.cyan,
                glowIntensity: 0.8,
                pulseSpeed: 1.0,
                borderWidth: 3.0,
              ),
              child: const Center(
                child: Text(
                  'Neon Effect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 