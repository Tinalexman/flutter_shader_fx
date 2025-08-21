import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A particle field effect painter that creates floating particles with physics.
/// 
/// This effect generates animated particles that float around with realistic
/// physics simulation. Currently uses a simplified implementation since shader
/// compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: ParticleFieldEffect(
///     particleCount: 100,
///     speed: 1.0,
///     size: 2.0,
///   ),
/// )
/// ```
class ParticleFieldEffect extends BaseShaderPainter {
  /// Creates a particle field effect painter.
  /// 
  /// [particleCount] is the number of particles to display.
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [size] controls the size of particles (0.5 to 5.0).
  /// [performanceLevel] determines the quality settings.
  ParticleFieldEffect({
    this.particleCount = 100,
    this.speed = 1.0,
    this.size = 2.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'particle_field.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Number of particles to display.
  final int particleCount;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  /// Size of particles (0.5 to 5.0).
  final double size;

  // Particle data
  late List<_Particle> _particles;
  late Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    _initializeParticles(size);
    _updateParticles(size);
    _paintParticles(canvas, size);
  }

  /// Initializes particles if not already done.
  void _initializeParticles(Size size) {
    if (_particles.isEmpty) {
      _random = Random(42); // Fixed seed for consistent pattern
      _particles = List.generate(
        _getAdjustedParticleCount(),
        (index) => _Particle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 2.0,
            (_random.nextDouble() - 0.5) * 2.0,
          ),
          size: _random.nextDouble() * this.size + 0.5,
          color: _getRandomParticleColor(),
        ),
      );
    }
  }

  /// Gets adjusted particle count based on performance level.
  int _getAdjustedParticleCount() {
    switch (performanceLevel) {
      case PerformanceLevel.low:
        return (particleCount * 0.3).round();
      case PerformanceLevel.medium:
        return (particleCount * 0.6).round();
      case PerformanceLevel.high:
        return particleCount;
    }
  }

  /// Updates particle positions and physics.
  void _updateParticles(Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    for (final particle in _particles) {
      // Update position
      particle.position += particle.velocity * speed;
      
      // Add some wave motion
      particle.position += Offset(
        sin(time + particle.position.dx * 0.01) * 0.5,
        cos(time + particle.position.dy * 0.01) * 0.5,
      );
      
      // Bounce off edges
      if (particle.position.dx <= 0 || particle.position.dx >= size.width) {
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      }
      if (particle.position.dy <= 0 || particle.position.dy >= size.height) {
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      }
      
      // Keep particles in bounds
      particle.position = Offset(
        particle.position.dx.clamp(0.0, size.width),
        particle.position.dy.clamp(0.0, size.height),
      );
      
      // Update color based on time
      particle.color = _getParticleColorAtTime(time, particle);
    }
  }

  /// Paints all particles on the canvas.
  void _paintParticles(Canvas canvas, Size size) {
    for (final particle in _particles) {
      // Create particle paint with glow effect
      final paint = Paint()
        ..color = particle.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      // Draw particle
      canvas.drawCircle(particle.position, particle.size, paint);
      
      // Draw connection lines to nearby particles
      _paintConnections(canvas, particle);
    }
  }

  /// Paints connection lines between nearby particles.
  void _paintConnections(Canvas canvas, _Particle particle) {
    const connectionDistance = 50.0;
    
    for (final other in _particles) {
      if (identical(particle, other)) continue;
      
      final distance = (particle.position - other.position).distance;
      if (distance < connectionDistance) {
        final opacity = (1.0 - distance / connectionDistance) * 0.3;
        final connectionPaint = Paint()
          ..color = particle.color.withOpacity(opacity)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(particle.position, other.position, connectionPaint);
      }
    }
  }

  /// Gets a random particle color.
  Color _getRandomParticleColor() {
    final colors = [
      const Color(0xFF00FFFF), // Cyan
      const Color(0xFF00FF00), // Green
      const Color(0xFFFFFF00), // Yellow
      const Color(0xFFFF00FF), // Magenta
      const Color(0xFF0080FF), // Blue
      const Color(0xFFFF8000), // Orange
    ];
    
    return colors[_random.nextInt(colors.length)];
  }

  /// Gets particle color at a specific time for animation.
  Color _getParticleColorAtTime(double time, _Particle particle) {
    final baseColor = _getRandomParticleColor();
    final hue = (time * 0.1 + particle.position.dx * 0.01) % 1.0;
    
    // Create animated color
    return HSVColor.fromAHSV(
      1.0,
      hue * 360.0,
      0.8,
      1.0,
    ).toColor();
  }

  @override
  bool shouldRepaint(covariant ParticleFieldEffect oldDelegate) {
    return particleCount != oldDelegate.particleCount ||
           speed != oldDelegate.speed ||
           size != oldDelegate.size ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Represents a single particle in the field.
class _Particle {
  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });

  Offset position;
  Offset velocity;
  double size;
  Color color;
} 