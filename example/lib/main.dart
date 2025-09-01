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
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: ShaderEffect.distortion(
                      performanceLevel: PerformanceLevel.medium,
                      intensity: 0.5,
                      speed: 1.0,
                      child: Container(
                        color: Colors.blue,
                        width: double.infinity,
                        height: 400,
                      ),
                    ),
                  ),

                  // ShaderBackground.plasma(
                  //   colors: [Colors.white, Colors.red],
                  //   size: const Size(double.infinity, 400),
                  //   speed: 1.25,
                  //   intensity: 0.75,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'Plasma',
                  //         style: TextStyle(
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       Text(
                  //         'This is a plasma effect',
                  //         style: TextStyle(color: Colors.white70, fontSize: 16),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // ShaderBackground.glitch(
                  //   colors: [Colors.white, Colors.blue],
                  //   glitchType: GlitchType.analog,
                  //   size: const Size(double.infinity, 400),
                  //   speed: 1.25,
                  //   intensity: 0.75,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'Digital Glitch',
                  //         style: TextStyle(
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //       Text(
                  //         'This is a digital glitch effect',
                  //         style: TextStyle(color: Colors.white70, fontSize: 16),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
