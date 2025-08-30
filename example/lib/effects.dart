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
    return Scaffold(
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
                  height: 50,
                  child: ShaderEffect.distortion(
                    performanceLevel: PerformanceLevel.medium,
                    intensity: 0.75,
                    speed: 1.25,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Distortion Effect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    );
  }
}
