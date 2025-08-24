import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class LiquidProgressLoading extends StatefulWidget {
  const LiquidProgressLoading({super.key});

  @override
  State<LiquidProgressLoading> createState() => _LiquidProgressLoadingState();
}

class _LiquidProgressLoadingState extends State<LiquidProgressLoading> {
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
        title: const Text('Liquid Progress Loading'),
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
              painter: LiquidProgressEffect(
                progress: _progress,
                liquidColor: Colors.cyan,
                speed: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 