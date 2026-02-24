import 'package:flutter/material.dart';
import 'package:bazar/features/products/presentation/all_products_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Список категорий
  static const List<Map<String, String>> categories = [
    {"title": "Фрукты", "image": "assets/icons/fruits.png"},
    {"title": "Овощи", "image": "assets/icons/vegetables.png"},
    {"title": "Молочные", "image": "assets/icons/dairy.png"},
    {"title": "Напитки", "image": "assets/icons/drinks.png"},
    {"title": "Сладости", "image": "assets/icons/sweets.png"},
    {"title": "Мясо", "image": "assets/icons/meat.png"},
    {"title": "Рыба", "image": "assets/icons/fish.png"},
  ];

  // Список товаров
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    // Можно добавить несколько товаров по умолчанию
    products = [
      {"title": "Яблоко", "price": 150, "image": "assets/icons/fruits.png", "category": "Фрукты"},
      {"title": "Молоко", "price": 250, "image": "assets/icons/dairy.png", "category": "Молочные"},
      {"title": "Морковь", "price": 100, "image": "assets/icons/vegetables.png", "category": "Овощи"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Категории"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                // Фильтруем товары по категории
                final categoryProducts = products
                    .where((p) => p["category"] == category["title"])
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProductsPage(
                      products: categoryProducts,
                      onAddProduct: (newProduct) {
                        setState(() {
                          products.add(newProduct);
                        });
                      },
                      categoryName: category["title"]!,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        category["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category["title"]!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}