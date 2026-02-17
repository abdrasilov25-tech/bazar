import 'package:flutter/material.dart';
import 'package:bazar/features/home/presentation/pages/entrance_page.dart';
import 'package:bazar/features/home/presentation/pages/home_page.dart';
import 'package:bazar/features/products/presentation/pages/products_page.dart';
import 'package:bazar/features/clothing/presentation/pages/clothing_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const EntrancePage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductsPage());
      case '/clothing':
        return MaterialPageRoute(builder: (_) => const ClothingPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Страница не найдена")),
          ),
        );
    }
  }
}