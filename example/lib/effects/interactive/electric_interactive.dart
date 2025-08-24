import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class ElectricInteractive extends StatefulWidget {
  const ElectricInteractive({super.key});

  @override
  State<ElectricInteractive> createState() => _ElectricInteractiveState();
}

class _ElectricInteractiveState extends State<ElectricInteractive> {
  List<Offset> _touchPath = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electric Interactive'),
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
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              _touchPath = [
                Offset(
                  details.localPosition.dx / MediaQuery.of(context).size.width,
                  details.localPosition.dy / MediaQuery.of(context).size.height,
                ),
              ];
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _touchPath.add(Offset(
                details.localPosition.dx / MediaQuery.of(context).size.width,
                details.localPosition.dy / MediaQuery.of(context).size.height,
              ));
            });
          },
          onPanEnd: (_) {
            setState(() {
              _touchPath = [];
            });
          },
          child: CustomPaint(
            painter: ElectricEffect(
              touchPath: _touchPath,
              intensity: 0.8,
              speed: 1.0,
            ),
            child: const Center(
              child: Text(
                'Draw with your finger to create electric arcs',
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