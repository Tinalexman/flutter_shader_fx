import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class GlassMorphDecorative extends StatefulWidget {
  const GlassMorphDecorative({super.key});

  @override
  State<GlassMorphDecorative> createState() => _GlassMorphDecorativeState();
}

class _GlassMorphDecorativeState extends State<GlassMorphDecorative> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glass Morph Decorative'),
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
              painter: GlassMorphEffect(
                blurRadius: 10.0,
                transparency: 0.3,
                borderColor: Colors.white,
                borderWidth: 1.0,
              ),
              child: const Center(
                child: Text(
                  'Glass Effect',
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