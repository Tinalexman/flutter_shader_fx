import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A magnetic effect painter that attracts visual elements to cursor/finger.
/// 
/// This effect creates magnetic-like attraction where visual elements
/// are drawn toward the touch position. Currently uses a simplified
/// implementation since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: MagneticEffect(
///     touchPosition: Offset(0.5, 0.5),
///     strength: 0.8,
///     particleCount: 50,
///   ),
/// )
/// ```
class MagneticEffect extends BaseShaderPainter {
  /// Creates a magnetic effect painter.
  /// 
  /// [touchPosition] is the current touch/cursor position (normalized).
  /// [strength] controls the magnetic attraction strength (0.0 to 1.0).
  /// [particleCount] is the number of particles to attract.
  /// [performanceLevel] determines the quality settings.
  MagneticEffect({
    this.touchPosition = const Offset(0.5, 0.5),
    this.strength = 0.8,
    this.particleCount = 50,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'magnetic.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Current touch/cursor position (normalized coordinates).
  final Offset touchPosition;

  /// Magnetic attraction strength (0.0 to 1.0).
  final double strength;

  /// Number of particles to attract.
  final int particleCount;

  // Particle data
  late List<_MagneticParticle> _particles;
  late Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    _initializeParticles(size);
    _updateParticles(size);
    _paintMagneticEffect(canvas, size);
  }

  /// Initializes particles if not already done.
  void _initializeParticles(Size size) {
    if (_particles.isEmpty) {
      _random = Random(42); // Fixed seed for consistent pattern
      _particles = List.generate(
        _getAdjustedParticleCount(),
        (index) => _MagneticParticle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset.zero,
          size: _random.nextDouble() * 4.0 + 1.0,
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

  /// Updates particle positions based on magnetic attraction.
  void _updateParticles(Size size) {
    final targetPosition = Offset(
      touchPosition.dx * size.width,
      touchPosition.dy * size.height,
    );
    
    for (final particle in _particles) {
      // Calculate distance to target
      final toTarget = targetPosition - particle.position;
      final distance = toTarget.distance;
      
      if (distance > 0) {
        // Calculate attraction force
        final attractionForce = strength / (distance + 1.0);
        final normalizedDirection = toTarget / distance;
        
        // Apply magnetic force
        particle.velocity += normalizedDirection * attractionForce * 2.0;
        
        // Add some damping
        particle.velocity *= 0.95;
        
        // Update position
        particle.position += particle.velocity;
        
        // Keep particles in bounds
        particle.position = Offset(
          particle.position.dx.clamp(0.0, size.width),
          particle.position.dy.clamp(0.0, size.height),
        );
      }
    }
  }

  /// Paints the magnetic effect with particles and field lines.
  void _paintMagneticEffect(Canvas canvas, Size size) {
    final targetPosition = Offset(
      touchPosition.dx * size.width,
      touchPosition.dy * size.height,
    );
    
    // Paint magnetic field lines
    _paintFieldLines(canvas, size, targetPosition);
    
    // Paint particles
    for (final particle in _particles) {
      _paintParticle(canvas, particle, targetPosition);
    }
    
    // Paint magnetic center
    _paintMagneticCenter(canvas, targetPosition);
  }

  /// Paints magnetic field lines.
  void _paintFieldLines(Canvas canvas, Size size, Offset center) {
    final lineCount = 8;
    final maxRadius = min(size.width, size.height) * 0.4;
    
    for (int i = 0; i < lineCount; i++) {
      final angle = (i / lineCount) * 2 * pi;
      final endPoint = center + Offset(
        cos(angle) * maxRadius,
        sin(angle) * maxRadius,
      );
      
      // Create gradient for field line
      final gradient = LinearGradient(
        begin: Alignment.center,
        end: Alignment.centerLeft,
        colors: [
          Colors.blue.withOpacity(0.8 * strength),
          Colors.blue.withOpacity(0.3 * strength),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromPoints(center, endPoint))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(center, endPoint, paint);
    }
  }

  /// Paints a single particle.
  void _paintParticle(Canvas canvas, _MagneticParticle particle, Offset center) {
    final distance = (particle.position - center).distance;
    final maxDistance = 200.0;
    final intensity = (1.0 - (distance / maxDistance).clamp(0.0, 1.0)) * strength;
    
    // Create particle glow
    final glowPaint = Paint()
      ..color = particle.color.withOpacity(intensity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(particle.position, particle.size * 2, glowPaint);
    
    // Create particle core
    final corePaint = Paint()
      ..color = particle.color.withOpacity(intensity);
    
    canvas.drawCircle(particle.position, particle.size, corePaint);
  }

  /// Paints the magnetic center.
  void _paintMagneticCenter(Canvas canvas, Offset center) {
    // Create center glow
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3 * strength)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawCircle(center, 30.0, glowPaint);
    
    // Create center core
    final corePaint = Paint()
      ..color = Colors.blue.withOpacity(0.8 * strength);
    
    canvas.drawCircle(center, 10.0, corePaint);
  }

  /// Gets a random particle color.
  Color _getRandomParticleColor() {
    final colors = [
      const Color(0xFF00FFFF), // Cyan
      const Color(0xFF0080FF), // Blue
      const Color(0xFF8000FF), // Purple
      const Color(0xFFFF0080), // Pink
    ];
    
    return colors[_random.nextInt(colors.length)];
  }

  @override
  bool shouldRepaint(covariant MagneticEffect oldDelegate) {
    return touchPosition != oldDelegate.touchPosition ||
           strength != oldDelegate.strength ||
           particleCount != oldDelegate.particleCount ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Represents a single magnetic particle.
class _MagneticParticle {
  _MagneticParticle({
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