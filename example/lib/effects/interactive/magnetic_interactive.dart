import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class MagneticInteractive extends StatefulWidget {
  const MagneticInteractive({super.key});

  @override
  State<MagneticInteractive> createState() => _MagneticInteractiveState();
}

class _MagneticInteractiveState extends State<MagneticInteractive> {
  Offset _touchPosition = const Offset(0.5, 0.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magnetic Interactive'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _touchPosition = Offset(
              details.localPosition.dx / MediaQuery.of(context).size.width,
              details.localPosition.dy / MediaQuery.of(context).size.height,
            );
          });
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.purple],
            ),
          ),
          child: CustomPaint(
            painter: MagneticEffect(
              touchPosition: _touchPosition,
              strength: 0.8,
              particleCount: 50,
            ),
            child: const Center(
              child: Text(
                'Move your finger to see magnetic attraction',
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
      ),
    );
  }
} 