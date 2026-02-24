import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  final String categoryName;
  final Function(Map<String, dynamic>) onAddProduct;

  const AddProductPage({
    super.key,
    required this.categoryName,
    required this.onAddProduct,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _image = "assets/icons/fruits.png"; // по умолчанию

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Добавить продукт")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Название"),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Цена"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final price = int.tryParse(_priceController.text.trim()) ?? 0;
                if (title.isNotEmpty && price > 0) {
                  widget.onAddProduct({
                    "title": title,
                    "price": price,
                    "image": _image,
                    "category": widget.categoryName,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}