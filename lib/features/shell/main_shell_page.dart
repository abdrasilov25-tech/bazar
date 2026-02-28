import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/home/presentation/pages/home_page.dart';
import 'package:bazar/features/shell/tabs/cart_tab.dart';
import 'package:bazar/features/shell/tabs/favorites_tab.dart';
import 'package:bazar/features/shell/tabs/profile_tab.dart';
import 'package:bazar/features/shell/tabs/sell_tab.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();

    final tabs = <Widget>[
      const HomePage(),
      const FavoritesTab(),
      const SellTab(),
      const CartTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: FutureBuilder(
        future: context.watch<AppSession>().ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return IndexedStack(index: _index, children: tabs);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Продать',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Покупки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

