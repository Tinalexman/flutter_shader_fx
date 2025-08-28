import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class Effects extends StatefulWidget {
  const Effects({super.key});

  @override
  State<Effects> createState() => _EffectsState();
}

class _EffectsState extends State<Effects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ShaderBackground.plasma());
  }
}
