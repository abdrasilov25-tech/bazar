// TODO Implement this library.import 'package:flutter/material.dart';

import 'package:flutter/material.dart'; // <- обязательно!

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("пиво")),
      body: const Center(
        child: Text("Здесь будут продукты"),
      ),
    );
  }
}