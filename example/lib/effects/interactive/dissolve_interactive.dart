import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class DissolveInteractive extends StatefulWidget {
  const DissolveInteractive({super.key});

  @override
  State<DissolveInteractive> createState() => _DissolveInteractiveState();
}

class _DissolveInteractiveState extends State<DissolveInteractive> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dissolve Interactive'),
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
                painter: DissolveEffect(
                  progress: _progress,
                  particleCount: 100,
                  dissolveColor: Colors.white,
                  speed: 1.0,
                ),
                child: const Center(
                  child: Text(
                    'Drag slider to see dissolve effect',
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
                value: _progress,
                onChanged: (value) => setState(() => _progress = value),
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