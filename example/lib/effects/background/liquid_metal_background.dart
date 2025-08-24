import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class LiquidMetalBackground extends StatefulWidget {
  const LiquidMetalBackground({super.key});

  @override
  State<LiquidMetalBackground> createState() => _LiquidMetalBackgroundState();
}

class _LiquidMetalBackgroundState extends State<LiquidMetalBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Metal Background'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ShaderBackground.liquidMetal(
        metallicness: 0.8,
        roughness: 0.2,
        speed: 1.0,
        child: const Center(
          child: Text(
            'Liquid Metal Effect',
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