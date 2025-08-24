import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class QuantumDotsLoading extends StatefulWidget {
  const QuantumDotsLoading({super.key});

  @override
  State<QuantumDotsLoading> createState() => _QuantumDotsLoadingState();
}

class _QuantumDotsLoadingState extends State<QuantumDotsLoading> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animateProgress();
  }

  void _animateProgress() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _progress = (_progress + 0.01) % 1.0;
        });
        _animateProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantum Dots Loading'),
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
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: QuantumDotsEffect(
                progress: _progress,
                dotColor: Colors.cyan,
                speed: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 