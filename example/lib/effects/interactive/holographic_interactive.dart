import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class HolographicInteractive extends StatefulWidget {
  const HolographicInteractive({super.key});

  @override
  State<HolographicInteractive> createState() => _HolographicInteractiveState();
}

class _HolographicInteractiveState extends State<HolographicInteractive> {
  double _viewingAngle = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holographic Interactive'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomPaint(
                painter: HolographicEffect(
                  viewingAngle: _viewingAngle,
                  intensity: 0.8,
                  speed: 1.0,
                ),
                child: const Center(
                  child: Text(
                    'Drag slider to change viewing angle',
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
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Slider(
                value: _viewingAngle,
                onChanged: (value) => setState(() => _viewingAngle = value),
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 