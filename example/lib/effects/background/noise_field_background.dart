import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class NoiseFieldBackground extends StatefulWidget {
  const NoiseFieldBackground({super.key});

  @override
  State<NoiseFieldBackground> createState() => _NoiseFieldBackgroundState();
}

class _NoiseFieldBackgroundState extends State<NoiseFieldBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noise Field Background'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ShaderBackground.noiseField(
        scale: 50.0,
        speed: 1.0,
        intensity: 0.8,
        child: const Center(
          child: Text(
            'Noise Field Effect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
} 