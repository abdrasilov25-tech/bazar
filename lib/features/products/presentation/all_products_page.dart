import 'package:flutter/material.dart';

class AllProductsPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String categoryName;
  final Function(Map<String, dynamic>) onAddProduct;

  const AllProductsPage({
    super.key,
    required this.products,
    required this.onAddProduct,
    required this.categoryName,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Категория: ${widget.categoryName}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddProductBottomSheet(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: widget.products.isEmpty
            ? const Center(child: Text("Нет товаров в этой категории"))
            : GridView.builder(
                itemCount: widget.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              product["image"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("${product["price"]} тг"),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showAddProductBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String image = "assets/icons/fruits.png"; // можно потом добавить выбор картинки

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // чтобы клавиатура не перекрывала
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Название"),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Цена"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                if (title.isNotEmpty && price > 0) {
                  widget.onAddProduct({
                    "title": title,
                    "price": price,
                    "image": image,
                    "category": widget.categoryName,
                  });
                  Navigator.pop(context);
                  setState(() {}); // обновляем GridView
                }
              },
              child: const Text("Сохранить"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}