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
      body: ShaderBackground.noiseField(
        // scale: 0.5,
        speed: 1.2,
        intensity: 1.0,
        child: Center(
          child: Text(
            "Noise Field Background",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
} 