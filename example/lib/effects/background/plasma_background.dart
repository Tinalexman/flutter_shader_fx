import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

class PlasmaBackground extends StatefulWidget {
  const PlasmaBackground({super.key});

  @override
  State<PlasmaBackground> createState() => _PlasmaBackgroundState();
}

class _PlasmaBackgroundState extends State<PlasmaBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ShaderBackground.plasma());
  }
}
