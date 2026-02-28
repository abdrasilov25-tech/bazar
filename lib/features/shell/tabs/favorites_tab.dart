import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/products/product.dart';
import 'package:bazar/features/products/presentation/product_details_page.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final _supabase = Supabase.instance.client;

  bool _loading = false;
  String? _error;
  List<Product> _products = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final fav = context.read<AppSession>().favorites.toList();
    if (fav.isEmpty) {
      setState(() {
        _products = const [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await _supabase
          .from('products')
          .select()
          .inFilter('id', fav)
          .order('created_at', ascending: false);

      final list = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromMap)
          .toList();

      if (!mounted) return;
      setState(() {
        _products = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FutureBuilder(
          future: session.ready,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (session.favorites.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 24),
                  Text(
                    'Пока пусто',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text('Добавляйте товары в избранное, чтобы не потерять.'),
                ],
              );
            }
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return ListView(
                children: [
                  const SizedBox(height: 24),
                  Text('Ошибка: $_error',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Повторить'),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: _products.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = _products[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: p),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: (p.mediaUrl.trim().isEmpty ||
                                    p.mediaType != 'image')
                                ? Image.asset(
                                    'assets/icons/fruits.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    p.mediaUrl,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Image.asset(
                                      'assets/icons/fruits.png',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.price} тг',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<AppSession>()
                                  .toggleFavorite(p.id);
                            },
                            icon: Icon(
                              session.isFavorite(p.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: session.isFavorite(p.id)
                                  ? Colors.red
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

