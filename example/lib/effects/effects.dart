import 'package:flutter/material.dart';

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
          "Effects Library",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}
