import 'package:flutter/material.dart';
import 'package:bazar/features/home/presentation/pages/entrance_page.dart';
import 'package:bazar/features/home/presentation/pages/splash_page.dart';
import 'package:bazar/features/products/presentation/pages/products_page.dart';
import 'package:bazar/features/clothing/presentation/pages/clothing_page.dart';
import 'package:bazar/features/shell/main_shell_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/entrance':
        return MaterialPageRoute(builder: (_) => const EntrancePage());
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainShellPage());
      case '/home': // backward compatibility
        return MaterialPageRoute(builder: (_) => const MainShellPage());
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