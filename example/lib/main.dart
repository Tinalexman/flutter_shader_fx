import 'package:flutter/material.dart';
import 'package:flutter_shader_fx/flutter_shader_fx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Shader FX Example",
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Effects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  ShaderBackground.plasma(
                    colors: [Colors.white, Colors.red],
                    size: const Size(double.infinity, 400),
                    speed: 1.25,
                    intensity: 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Plasma',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'This is a plasma effect',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ShaderBackground.glitch(
                    colors: [Colors.cyan, Colors.pink],
                    glitchType: GlitchType.analog,
                    size: const Size(double.infinity, 400),
                    speed: 1.25,
                    intensity: 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Analog Glitch',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'VHS-style artifacts with scanlines',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ShaderBackground.glitch(
                    colors: [Colors.red, Colors.green],
                    glitchType: GlitchType.digital,
                    size: const Size(double.infinity, 400),
                    speed: 1.5,
                    intensity: 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Digital Glitch',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'RGB splitting with block displacement',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
