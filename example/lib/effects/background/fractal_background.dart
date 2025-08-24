import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class FractalBackground extends StatefulWidget {
  const FractalBackground({super.key});

  @override
  State<FractalBackground> createState() => _FractalBackgroundState();
}

class _FractalBackgroundState extends State<FractalBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fractal Background'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ShaderBackground.fractal(
        zoom: 1.0,
        center: const Offset(0.5, 0.5),
        maxIterations: 100,
        child: const Center(
          child: Text(
            'Fractal Effect',
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