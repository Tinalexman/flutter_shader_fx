import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class ParticleFieldBackground extends StatefulWidget {
  const ParticleFieldBackground({super.key});

  @override
  State<ParticleFieldBackground> createState() => _ParticleFieldBackgroundState();
}

class _ParticleFieldBackgroundState extends State<ParticleFieldBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Particle Field Background'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ShaderBackground.particleField(
        particleCount: 100,
        speed: 1.0,
        particleSize: 2.0,
        child: const Center(
          child: Text(
            'Particle Field Effect',
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