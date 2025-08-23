import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A quantum dots effect painter that creates particle system loader with physics.
/// 
/// This effect creates quantum dots that move with realistic physics and
/// form patterns based on progress. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: QuantumDotsEffect(
///     progress: 0.7,
///     dotColor: Colors.cyan,
///     speed: 1.0,
///   ),
/// )
/// ```
class QuantumDotsEffect extends BaseShaderPainter {
  /// Creates a quantum dots effect painter.
  /// 
  /// [progress] is the progress value (0.0 to 1.0).
  /// [dotColor] is the color of the quantum dots.
  /// [speed] controls the animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  QuantumDotsEffect({
    this.progress = 0.0,
    this.dotColor = Colors.cyan,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'quantum_dots.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Progress value (0.0 to 1.0).
  final double progress;

  /// Color of the quantum dots.
  final Color dotColor;

  /// Animation speed (0.5 to 2.0).
  final double speed;

  // Particle data
  late List<_QuantumDot> _dots;
  late Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    _initializeDots(size);
    _updateDots(size);
    _paintQuantumDots(canvas, size);
  }

  /// Initializes quantum dots if not already done.
  void _initializeDots(Size size) {
    if (_dots.isEmpty) {
      _random = Random(42); // Fixed seed for consistent pattern
      _dots = List.generate(
        _getAdjustedDotCount(),
        (index) => _QuantumDot(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 2.0,
            (_random.nextDouble() - 0.5) * 2.0,
          ),
          size: _random.nextDouble() * 4.0 + 2.0,
          energy: _random.nextDouble(),
          phase: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  /// Gets adjusted dot count based on performance level.
  int _getAdjustedDotCount() {
    final baseCount = 30;
    switch (performanceLevel) {
      case PerformanceLevel.low:
        return (baseCount * 0.3).round();
      case PerformanceLevel.medium:
        return (baseCount * 0.6).round();
      case PerformanceLevel.high:
        return baseCount;
    }
  }

  /// Updates quantum dot positions and physics.
  void _updateDots(Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final dot in _dots) {
      // Update energy based on progress
      dot.energy = (progress + sin(time + dot.phase) * 0.1).clamp(0.0, 1.0);
      
      // Calculate quantum field influence
      final toCenter = center - dot.position;
      final distance = toCenter.distance;
      final fieldStrength = progress / (distance + 1.0);
      
      // Apply quantum field force
      if (distance > 0) {
        final fieldDirection = toCenter / distance;
        dot.velocity += fieldDirection * fieldStrength * 0.5;
      }
      
      // Add quantum fluctuations
      dot.velocity += Offset(
        sin(time * 3 + dot.phase) * 0.1,
        cos(time * 3 + dot.phase) * 0.1,
      );
      
      // Apply damping
      dot.velocity *= 0.98;
      
      // Update position
      dot.position += dot.velocity;
      
      // Keep dots in bounds with quantum tunneling effect
      if (dot.position.dx < 0 || dot.position.dx > size.width) {
        dot.position = Offset(
          dot.position.dx.clamp(0.0, size.width),
          dot.position.dy,
        );
        dot.velocity = Offset(-dot.velocity.dx * 0.5, dot.velocity.dy);
      }
      
      if (dot.position.dy < 0 || dot.position.dy > size.height) {
        dot.position = Offset(
          dot.position.dx,
          dot.position.dy.clamp(0.0, size.height),
        );
        dot.velocity = Offset(dot.velocity.dx, -dot.velocity.dy * 0.5);
      }
    }
  }

  /// Paints the quantum dots effect.
  void _paintQuantumDots(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    // Paint quantum field
    _paintQuantumField(canvas, size, time);
    
    // Paint quantum dots
    for (final dot in _dots) {
      _paintQuantumDot(canvas, dot, time);
    }
    
    // Paint quantum connections
    _paintQuantumConnections(canvas, size);
    
    // Paint progress indicator
    _paintProgressIndicator(canvas, size);
  }

  /// Paints the quantum field background.
  void _paintQuantumField(Canvas canvas, Size size, double time) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.6;
    
    // Create quantum field gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        dotColor.withOpacity(0.1 * progress),
        dotColor.withOpacity(0.05 * progress),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: center,
          width: maxRadius * 2,
          height: maxRadius * 2,
        ),
      );
    
    canvas.drawCircle(center, maxRadius, paint);
  }

  /// Paints a single quantum dot.
  void _paintQuantumDot(Canvas canvas, _QuantumDot dot, double time) {
    final energy = dot.energy;
    final size = dot.size * (0.5 + energy * 0.5);
    
    // Create quantum glow
    final glowPaint = Paint()
      ..color = dotColor.withOpacity(energy * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(dot.position, size * 2, glowPaint);
    
    // Create quantum core
    final corePaint = Paint()
      ..color = dotColor.withOpacity(energy * 0.8);
    
    canvas.drawCircle(dot.position, size, corePaint);
    
    // Create quantum pulse
    final pulseOpacity = energy * (0.5 + 0.5 * sin(time * 2 + dot.phase));
    final pulsePaint = Paint()
      ..color = dotColor.withOpacity(pulseOpacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawCircle(dot.position, size * 3, pulsePaint);
  }

  /// Paints quantum connections between dots.
  void _paintQuantumConnections(Canvas canvas, Size size) {
    final connectionDistance = min(size.width, size.height) * 0.15;
    
    for (int i = 0; i < _dots.length; i++) {
      for (int j = i + 1; j < _dots.length; j++) {
        final dot1 = _dots[i];
        final dot2 = _dots[j];
        final distance = (dot1.position - dot2.position).distance;
        
        if (distance < connectionDistance) {
          final opacity = (1.0 - distance / connectionDistance) * 0.3 * progress;
          
          if (opacity > 0.01) {
            final paint = Paint()
              ..color = dotColor.withOpacity(opacity)
              ..strokeWidth = 1.0
              ..style = PaintingStyle.stroke
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
            
            canvas.drawLine(dot1.position, dot2.position, paint);
          }
        }
      }
    }
  }

  /// Paints the progress indicator.
  void _paintProgressIndicator(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final percentage = (progress * 100).round();
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$percentage%',
        style: TextStyle(
          color: dotColor,
          fontSize: size.height * 0.15,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant QuantumDotsEffect oldDelegate) {
    return progress != oldDelegate.progress ||
           dotColor != oldDelegate.dotColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Represents a single quantum dot.
class _QuantumDot {
  _QuantumDot({
    required this.position,
    required this.velocity,
    required this.size,
    required this.energy,
    required this.phase,
  });

  Offset position;
  Offset velocity;
  double size;
  double energy;
  double phase;
} 