import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/base_shader_painter.dart';
import '../../core/performance_manager.dart';

/// An electric effect painter that creates lightning/electricity following touch path.
/// 
/// This effect creates electric arcs and lightning that follow touch paths
/// with realistic branching and flickering. Currently uses a simplified
/// implementation since shader compilation is not yet available.
/// 
/// ## Usage
/// 
/// ```dart
/// CustomPaint(
///   painter: ElectricEffect(
///     touchPath: [Offset(0.2, 0.5), Offset(0.8, 0.5)],
///     intensity: 0.8,
///     speed: 1.0,
///   ),
/// )
/// ```
class ElectricEffect extends BaseShaderPainter {
  /// Creates an electric effect painter.
  /// 
  /// [touchPath] is the path of touch points to follow.
  /// [intensity] controls the electric intensity (0.0 to 1.0).
  /// [speed] controls the animation speed (0.5 to 2.0).
  /// [performanceLevel] determines the quality settings.
  ElectricEffect({
    this.touchPath = const [],
    this.intensity = 0.8,
    this.speed = 1.0,
    PerformanceLevel? performanceLevel,
  }) : super(
    shaderPath: 'electric.frag',
    performanceLevel: performanceLevel ?? PerformanceLevel.medium,
  );

  /// Path of touch points to follow.
  final List<Offset> touchPath;

  /// Electric intensity (0.0 to 1.0).
  final double intensity;

  /// Animation speed (0.5 to 2.0).
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    _paintElectricEffect(canvas, size);
  }

  /// Paints the electric effect.
  void _paintElectricEffect(Canvas canvas, Size size) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0 * speed;
    
    if (touchPath.length >= 2) {
      // Paint main electric arc
      _paintMainArc(canvas, size, time);
      
      // Paint electric branches
      _paintElectricBranches(canvas, size, time);
      
      // Paint electric particles
      _paintElectricParticles(canvas, size, time);
      
      // Paint electric glow
      _paintElectricGlow(canvas, size, time);
    }
  }

  /// Paints the main electric arc.
  void _paintMainArc(Canvas canvas, Size size, double time) {
    final path = Path();
    final points = _generateElectricPath(touchPath, time);
    
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
      }
      
      // Create electric gradient
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.cyan.withOpacity(intensity * 0.8),
          Colors.white.withOpacity(intensity),
          Colors.cyan.withOpacity(intensity * 0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(Offset.zero & size)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawPath(path, paint);
    }
  }

  /// Paints electric branches.
  void _paintElectricBranches(Canvas canvas, Size size, double time) {
    final branchCount = 3;
    
    for (int i = 0; i < branchCount; i++) {
      final branchStart = touchPath[touchPath.length ~/ 2];
      final branchEnd = Offset(
        branchStart.dx + (sin(time + i) * 0.2),
        branchStart.dy + (cos(time + i) * 0.2),
      );
      
      final branchPath = _generateElectricPath([branchStart, branchEnd], time + i);
      
      if (branchPath.length >= 2) {
        final path = Path();
        path.moveTo(branchPath[0].dx * size.width, branchPath[0].dy * size.height);
        
        for (int j = 1; j < branchPath.length; j++) {
          path.lineTo(branchPath[j].dx * size.width, branchPath[j].dy * size.height);
        }
        
        final paint = Paint()
          ..color = Colors.cyan.withOpacity(intensity * 0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        
        canvas.drawPath(path, paint);
      }
    }
  }

  /// Paints electric particles.
  void _paintElectricParticles(Canvas canvas, Size size, double time) {
    final particleCount = 20;
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (time + i * 0.1) % 1.0;
      final pathIndex = (progress * (touchPath.length - 1)).floor();
      
      if (pathIndex < touchPath.length - 1) {
        final t = (progress * (touchPath.length - 1)) - pathIndex;
        final start = touchPath[pathIndex];
        final end = touchPath[pathIndex + 1];
        
        final position = Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        );
        
        // Add some randomness
        final randomOffset = Offset(
          (sin(time * 10 + i) * 0.02),
          (cos(time * 10 + i) * 0.02),
        );
        
        final particlePos = position + randomOffset;
        final particleOpacity = (sin(time * 5 + i) + 1.0) / 2.0 * intensity;
        
        if (particleOpacity > 0.1) {
          final paint = Paint()
            ..color = Colors.white.withOpacity(particleOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          
          canvas.drawCircle(
            Offset(particlePos.dx * size.width, particlePos.dy * size.height),
            3.0,
            paint,
          );
        }
      }
    }
  }

  /// Paints electric glow.
  void _paintElectricGlow(Canvas canvas, Size size, double time) {
    if (touchPath.length >= 2) {
      final start = touchPath.first;
      final end = touchPath.last;
      
      // Create glow at start and end points
      _paintElectricGlowPoint(canvas, size, start, time, 'start');
      _paintElectricGlowPoint(canvas, size, end, time, 'end');
    }
  }

  /// Paints electric glow at a specific point.
  void _paintElectricGlowPoint(Canvas canvas, Size size, Offset point, double time, String type) {
    final glowRadius = type == 'start' ? 30.0 : 40.0;
    final glowOpacity = intensity * (0.5 + 0.5 * sin(time * 3));
    
    // Create glow gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.cyan.withOpacity(glowOpacity * 0.8),
        Colors.cyan.withOpacity(glowOpacity * 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCenter(
          center: Offset(point.dx * size.width, point.dy * size.height),
          width: glowRadius * 2,
          height: glowRadius * 2,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawCircle(
      Offset(point.dx * size.width, point.dy * size.height),
      glowRadius,
      paint,
    );
  }

  /// Generates electric path with lightning-like variations.
  List<Offset> _generateElectricPath(List<Offset> basePath, double time) {
    if (basePath.length < 2) return basePath;
    
    final result = <Offset>[];
    final segmentCount = 10;
    
    for (int i = 0; i < basePath.length - 1; i++) {
      final start = basePath[i];
      final end = basePath[i + 1];
      
      for (int j = 0; j <= segmentCount; j++) {
        final t = j / segmentCount;
        final basePoint = Offset(
          start.dx + (end.dx - start.dx) * t,
          start.dy + (end.dy - start.dy) * t,
        );
        
        // Add lightning-like variation
        final variation = Offset(
          sin(time * 5 + i * 10 + j) * 0.02,
          cos(time * 5 + i * 10 + j) * 0.02,
        );
        
        result.add(basePoint + variation);
      }
    }
    
    return result;
  }

  @override
  bool shouldRepaint(covariant ElectricEffect oldDelegate) {
    return touchPath != oldDelegate.touchPath ||
           intensity != oldDelegate.intensity ||
           speed != oldDelegate.speed ||
           performanceLevel != oldDelegate.performanceLevel;
  }
} 