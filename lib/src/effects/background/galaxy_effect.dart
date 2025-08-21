import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// A galaxy effect painter that creates spiral galaxy with twinkling stars.
/// 
/// This effect generates a beautiful spiral galaxy with animated stars
/// and nebula-like clouds. Currently uses a simplified implementation
/// since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: GalaxyEffect(
///     starCount: 200,
///     spiralArms: 4,
///     speed: 1.0,
///   ),
/// )
/// ```
class GalaxyEffect extends BaseShaderPainter {
  /// Creates a galaxy effect painter.
  /// 
  /// [starCount] is the number of stars to display.
  /// [spiralArms] is the number of spiral arms (2 to 6).
  /// [speed] controls the animation speed (0.0 to 2.0).
  /// [performanceLevel] determines the quality settings.
  GalaxyEffect({
    this.starCount = 200,
    this.spiralArms = 4,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'galaxy.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Number of stars to display.
  final int starCount;

  /// Number of spiral arms (2 to 6).
  final int spiralArms;

  /// Animation speed (0.0 to 2.0).
  final double speed;

  // Star data
  late List<_Star> _stars;
  late Random _random;

  @override
  void paint(Canvas canvas, Size size) {
    _initializeStars(size);
    _updateStars(size);
    _paintGalaxy(canvas, size);
  }

  /// Initializes stars if not already done.
  void _initializeStars(Size size) {
    if (_stars.isEmpty) {
      _random = Random(42); // Fixed seed for consistent pattern
      _stars = List.generate(
        _getAdjustedStarCount(),
        (index) => _Star(
          position: _generateStarPosition(size),
          size: _random.nextDouble() * 3.0 + 0.5,
          brightness: _random.nextDouble(),
          color: _getRandomStarColor(),
        ),
      );
    }
  }

  /// Gets adjusted star count based on performance level.
  int _getAdjustedStarCount() {
    switch (performanceLevel) {
      case PerformanceLevel.low:
        return (starCount * 0.3).round();
      case PerformanceLevel.medium:
        return (starCount * 0.6).round();
      case PerformanceLevel.high:
        return starCount;
    }
  }

  /// Generates star position in spiral pattern.
  Offset _generateStarPosition(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) * 0.4;
    
    // Generate spiral position
    final angle = _random.nextDouble() * 2 * pi;
    final radius = _random.nextDouble() * maxRadius;
    
    // Add spiral arm offset
    final armOffset = (angle * spiralArms / (2 * pi)).floor() * (2 * pi / spiralArms);
    final spiralAngle = angle + armOffset + radius * 0.01;
    
    return center + Offset(
      cos(spiralAngle) * radius,
      sin(spiralAngle) * radius,
    );
  }

  /// Updates star animations.
  void _updateStars(Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    for (final star in _stars) {
      // Twinkle effect
      star.brightness = 0.5 + 0.5 * sin(time * 2 + star.position.dx * 0.01);
      
      // Rotate stars around center
      final center = Offset(size.width / 2, size.height / 2);
      final toCenter = center - star.position;
      final distance = toCenter.distance;
      
      if (distance > 0) {
        final rotationSpeed = 0.1 / (distance + 1.0);
        final angle = atan2(toCenter.dy, toCenter.dx) + rotationSpeed * time;
        final newRadius = distance;
        
        star.position = center + Offset(
          cos(angle) * newRadius,
          sin(angle) * newRadius,
        );
      }
    }
  }

  /// Paints the galaxy with stars and nebula.
  void _paintGalaxy(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Paint nebula background
    _paintNebula(canvas, size, center);
    
    // Paint stars
    for (final star in _stars) {
      _paintStar(canvas, star);
    }
  }

  /// Paints nebula background.
  void _paintNebula(Canvas canvas, Size size, Offset center) {
    final maxRadius = min(size.width, size.height) * 0.5;
    
    // Create nebula gradient
    final nebulaGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        const Color(0xFF1a0033), // Dark purple
        const Color(0xFF330066), // Purple
        const Color(0xFF660099), // Light purple
        const Color(0xFF9900CC), // Pink
        const Color(0xFFCC00FF), // Bright pink
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );
    
    final nebulaPaint = Paint()
      ..shader = nebulaGradient.createShader(Offset.zero & size);
    
    canvas.drawCircle(center, maxRadius, nebulaPaint);
  }

  /// Paints a single star.
  void _paintStar(Canvas canvas, _Star star) {
    // Create star glow
    final glowPaint = Paint()
      ..color = star.color.withOpacity(star.brightness * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(star.position, star.size * 2, glowPaint);
    
    // Create star core
    final corePaint = Paint()
      ..color = star.color.withOpacity(star.brightness);
    
    canvas.drawCircle(star.position, star.size, corePaint);
  }

  /// Gets a random star color.
  Color _getRandomStarColor() {
    final colors = [
      const Color(0xFFFFFFFF), // White
      const Color(0xFFFFF0E6), // Warm white
      const Color(0xFFE6F3FF), // Cool white
      const Color(0xFFFFE6E6), // Pink white
      const Color(0xFFE6FFE6), // Green white
      const Color(0xFFFFF0E6), // Yellow white
    ];
    
    return colors[_random.nextInt(colors.length)];
  }

  @override
  bool shouldRepaint(covariant GalaxyEffect oldDelegate) {
    return starCount != oldDelegate.starCount ||
           spiralArms != oldDelegate.spiralArms ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
}

/// Represents a single star in the galaxy.
class _Star {
  _Star({
    required this.position,
    required this.size,
    required this.brightness,
    required this.color,
  });

  Offset position;
  double size;
  double brightness;
  Color color;
} 