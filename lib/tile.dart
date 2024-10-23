import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  bool lightOn;
  Tile({super.key, required this.lightOn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      color: lightOn ? Colors.white : Colors.grey[900],
    );
  }
}
