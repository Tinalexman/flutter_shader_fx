import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class BokehDecorative extends StatefulWidget {
  const BokehDecorative({super.key});

  @override
  State<BokehDecorative> createState() => _BokehDecorativeState();
}

class _BokehDecorativeState extends State<BokehDecorative> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bokeh Decorative'),
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
              painter: BokehEffect(
                focusPoint: const Offset(0.5, 0.5),
                focusDepth: 0.5,
                bokehIntensity: 0.8,
              ),
              child: const Center(
                child: Text(
                  'Bokeh Effect',
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