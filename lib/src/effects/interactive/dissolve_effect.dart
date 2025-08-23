import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A dissolve effect painter that creates particle dissolve transition between states.
/// 
/// This effect creates particle-based dissolve animations for smooth
/// transitions between states. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: DissolveEffect(
///     progress: 0.5,
///     particleCount: 100,
///     dissolveColor: Colors.white,
///   ),
/// )
/// ```
class DissolveEffect extends BaseShaderPainter {
  /// Creates a dissolve effect painter.
  /// 
  /// [progress] is the dissolve progress (0.0 to 1.0).
  /// [particleCount] is the number of particles for the dissolve effect.
  /// [dissolveColor] is the color of the dissolving particles.
  /// [speed] controls the dissolve animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  DissolveEffect({
    this.progress = 0.0,
    this.particleCount = 100,
    this.dissolveColor = Colors.white,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'dissolve.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Dissolve progress (0.0 to 1.0).
  final double progress;

  /// Number of particles for the dissolve effect.
  final int particleCount;

  /// Color of the dissolving particles.
  final Color dissolveColor;

  /// Dissolve animation speed (0.5 to 2.0).
  final double speed;

  // Particle data
  late List<_DissolveParticle> _particles;
  late Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    _initializeParticles(size);
    _updateParticles(size);
    _paintDissolveEffect(canvas, size);
  }

  /// Initializes particles if not already done.
  void _initializeParticles(Size size) {
    if (_particles.isEmpty) {
      _random = Random(42); // Fixed seed for consistent pattern
      _particles = List.generate(
        _getAdjustedParticleCount(),
        (index) => _DissolveParticle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 2.0,
            (_random.nextDouble() - 0.5) * 2.0,
          ),
          size: _random.nextDouble() * 3.0 + 1.0,
          life: _random.nextDouble(),
          maxLife: _random.nextDouble() * 0.5 + 0.5,
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

  /// Updates particle positions and life cycles.
  void _updateParticles(Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    for (final particle in _particles) {
      // Update life based on progress
      particle.life = (progress + time * 0.1) % 1.0;
      
      // Update position
      particle.position += particle.velocity * speed;
      
      // Add some wave motion
      particle.position += Offset(
        sin(time + particle.position.dx * 0.01) * 0.5,
        cos(time + particle.position.dy * 0.01) * 0.5,
      );
      
      // Keep particles in bounds
      particle.position = Offset(
        particle.position.dx.clamp(-50.0, size.width + 50.0),
        particle.position.dy.clamp(-50.0, size.height + 50.0),
      );
      
      // Reset particles that go out of bounds
      if (particle.position.dx < -50.0 || 
          particle.position.dx > size.width + 50.0 ||
          particle.position.dy < -50.0 || 
          particle.position.dy > size.height + 50.0) {
        particle.position = Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        );
        particle.life = 0.0;
      }
    }
  }

  /// Paints the dissolve effect.
  void _paintDissolveEffect(Canvas canvas, Size size) {
    // Paint dissolve particles
    for (final particle in _particles) {
      _paintDissolveParticle(canvas, particle);
    }
    
    // Paint dissolve overlay
    _paintDissolveOverlay(canvas, size);
  }

  /// Paints a single dissolve particle.
  void _paintDissolveParticle(Canvas canvas, _DissolveParticle particle) {
    final lifeProgress = particle.life / particle.maxLife;
    final opacity = (1.0 - lifeProgress) * 0.8;
    
    if (opacity > 0.01) {
      // Create particle glow
      final glowPaint = Paint()
        ..color = dissolveColor.withOpacity(opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(particle.position, particle.size * 2, glowPaint);
      
      // Create particle core
      final corePaint = Paint()
        ..color = dissolveColor.withOpacity(opacity);
      
      canvas.drawCircle(particle.position, particle.size, corePaint);
    }
  }

  /// Paints the dissolve overlay.
  void _paintDissolveOverlay(Canvas canvas, Size size) {
    if (progress > 0.0) {
      // Create dissolve noise pattern
      final noisePaint = Paint();
      
      for (int y = 0; y < size.height; y += 4) {
        for (int x = 0; x < size.width; x += 4) {
          final noiseValue = _getNoiseValue(x, y, progress);
          final opacity = noiseValue * progress * 0.3;
          
          if (opacity > 0.01) {
            noisePaint.color = dissolveColor.withOpacity(opacity);
            canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 2.0, noisePaint);
          }
        }
      }
    }
  }

  /// Gets noise value for dissolve pattern.
  double _getNoiseValue(int x, int y, double progress) {
    final noise1 = _hash(x * 12.9898 + y * 78.233 + progress * 100);
    final noise2 = _hash(x * 37.719 + y * 49.123 + progress * 200);
    final noise3 = _hash(x * 23.456 + y * 67.890 + progress * 300);
    
    return (noise1 + noise2 + noise3) / 3.0;
  }

  /// Hash function for noise generation.
  double _hash(double n) {
    return (sin(n) * 43758.5453).abs() % 1.0;
  }

  @override
  bool shouldRepaint(covariant DissolveEffect oldDelegate) {
    return progress != oldDelegate.progress ||
           particleCount != oldDelegate.particleCount ||
           dissolveColor != oldDelegate.dissolveColor ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Represents a single dissolve particle.
class _DissolveParticle {
  _DissolveParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.life,
    required this.maxLife,
  });

  Offset position;
  Offset velocity;
  double size;
  double life;
  double maxLife;
} 