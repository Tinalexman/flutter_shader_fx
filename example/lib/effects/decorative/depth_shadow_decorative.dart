import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class DepthShadowDecorative extends StatefulWidget {
  const DepthShadowDecorative({super.key});

  @override
  State<DepthShadowDecorative> createState() => _DepthShadowDecorativeState();
}

class _DepthShadowDecorativeState extends State<DepthShadowDecorative> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depth Shadow Decorative'),
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
              painter: DepthShadowEffect(
                lightPosition: const Offset(0.3, 0.2),
                shadowIntensity: 0.8,
                depth: 0.5,
              ),
              child: const Center(
                child: Text(
                  'Depth Effect',
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