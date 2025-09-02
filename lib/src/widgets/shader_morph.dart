import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class ShaderMorph extends StatefulWidget {
  const ShaderMorph({
    super.key,
    this.controller,
    // required this.from,
    // required this.to,
  });

  /// The controller driving the animation
  final EffectController? controller;
  
  /// The SDF Shape we are morphing from
  // final SDFShape from;
  
  /// The SDF Shape we are morphing to
  // final SDFShape to;

  @override
  State<ShaderMorph> createState() => _ShaderMorphState();
}

class _ShaderMorphState extends State<ShaderMorph> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
