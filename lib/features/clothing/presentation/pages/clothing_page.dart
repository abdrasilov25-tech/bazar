// TODO Implement this library.import 'package:flutter/material.dart';

import 'package:flutter/material.dart'; // <- обязательно!

class ClothingPage extends StatelessWidget {
  const ClothingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Одежда")),
      body: const Center(
        child: Text("Здесь будет одежда"),
      ),
    );
  }
}