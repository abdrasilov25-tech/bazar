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
                    hintText: 'что ищете?',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'снизу ознакомьтесь с категориями bazar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<MarketCubit, List<MarketCategory>>(
              builder: (context, categories) {
                return GridView.count(
                  crossAxisCount: 2,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  childAspectRatio: 0.6,
                  children: categories.map((category) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, category.route);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            category.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
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