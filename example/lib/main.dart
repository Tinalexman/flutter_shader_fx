import 'package:flutter/material.dart';
import 'package:flutter_shader_fx_example/effects/effects.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Color color = const Color(0xFF101010);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter FX Examples",
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        fontFamily: "Outfit",
        scaffoldBackgroundColor: color,
        appBarTheme: AppBarTheme(color: color),
      ),
      home: const Effects(),
    );
  }
}
