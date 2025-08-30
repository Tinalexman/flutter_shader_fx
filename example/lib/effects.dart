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
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        title: Text(
          'Effects',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
                //           color: Colors.white,
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
                // ShaderBackground.digitalGlitch(
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
                //           color: Colors.white,
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
