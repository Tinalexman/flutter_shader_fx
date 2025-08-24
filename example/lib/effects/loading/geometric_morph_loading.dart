import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class GeometricMorphLoading extends StatefulWidget {
  const GeometricMorphLoading({super.key});

  @override
  State<GeometricMorphLoading> createState() => _GeometricMorphLoadingState();
}

class _GeometricMorphLoadingState extends State<GeometricMorphLoading> {
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
        title: const Text('Geometric Morph Loading'),
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
              painter: GeometricMorphEffect(
                progress: _progress,
                morphColor: Colors.purple,
                speed: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 