import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bazar/features/home/presentation/cubit/market_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MarketCubit>().loadCategories();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Обработка навигации
    switch (index) {
      case 0:
        // Главная - остаемся на этой странице
        break;
      case 1:
        // Корзина
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Корзина')),
        );
        break;
      case 2:
        // Избранное
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Избранное')),
        );
        break;
      case 3:
        // Профиль
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Центральный рынок"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              // Background Image
              Image.asset(
                "assets/images/background.png",
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Dark overlay gradient
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Search bar
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск товаров...',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: BlocBuilder<MarketCubit, List<MarketCategory>>(
              builder: (context, categories) {
                return Column(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, category.route);
                        },
                        child: Text(category.title),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 24)),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Text('🛒', style: TextStyle(fontSize: 24)),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Text('❤️', style: TextStyle(fontSize: 24)),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 24)),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}