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
    return Scaffold(
      body: ShaderBackground.plasma(
        colors: [Colors.pink, Colors.green],
        speed: 1.2,
        intensity: 1.0,
        child: Center(
          child: Text(
            "Plasma Background",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
