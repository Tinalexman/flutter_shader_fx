import 'package:flutter/material.dart';
import 'package:flutter_shader_fx_example/effects.dart';

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
      home: const Effects(),
    );
  }
}
