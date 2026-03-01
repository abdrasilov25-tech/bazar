import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/products/product.dart';
import 'package:bazar/features/products/presentation/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/home/presentation/cubit/market_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  List<Product> _recommended = [];
  bool _recommendedLoading = false;
  String? _loadedRecommendedPhone;

  @override
  void initState() {
    super.initState();
    context.read<MarketCubit>().loadCategories();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final phone = context.read<AppSession>().sellerPhone.trim();
    if (phone != _loadedRecommendedPhone) {
      _loadedRecommendedPhone = phone;
      _loadRecommended();
    }
  }

  Future<void> _loadRecommended() async {
    final session = context.read<AppSession>();
    final phone = session.sellerPhone.trim();
    if (phone.isEmpty) {
      if (mounted) setState(() => _recommended = []);
      return;
    }
    if (!mounted) return;
    setState(() => _recommendedLoading = true);
    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select()
          .eq('seller_phone', phone)
          .order('created_at', ascending: false)
          .limit(20);
      if (!mounted) return;
      final list = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromMap)
          .toList();
      setState(() {
        _recommended = list;
        _recommendedLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _recommended = [];
        _recommendedLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const double _categorySize = 64.0;
  static const double _categoryColumnWidth = 80.0;

  Widget _buildRoundCategory(MarketCategory c) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, c.route),
          borderRadius: BorderRadius.circular(_categorySize / 2 + 8),
          child: SizedBox(
            width: _categoryColumnWidth,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: _categorySize,
                    height: _categorySize,
                    child: Image.asset(
                      c.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedProductCard(Product p) {
    final session = context.watch<AppSession>();
    final url = p.mediaUrl.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: p),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (url.isEmpty)
                    const ColoredBox(
                      color: Color(0xFFF0F0F0),
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 32),
                      ),
                    )
                  else
                    Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFF0F0F0),
                        child: Center(
                          child: Icon(Icons.broken_image, size: 32),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => context.read<AppSession>().toggleFavorite(p.id),
                      child: Icon(
                        session.isFavorite(p.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: session.isFavorite(p.id) ? Colors.red : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.price} тг',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bazar"),
        actions: [
          if (session.isSeller)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Продавец',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Покупатель',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MarketCubit, List<MarketCategory>>(
          builder: (context, categories) {
            final filtered = categories.where((category) {
              final title = category.title.toLowerCase();
              return title.contains(_searchQuery);
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Поиск в Bazar',
                            prefixIcon: Icon(Icons.search_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(16),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(28),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Найдите товары рядом и пишите продавцу в WhatsApp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Категории',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                filtered.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Center(child: Text('Категории не найдены')),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: SizedBox(
                          height: 2 * (_categorySize + 6 + 36) + 8,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: (filtered.length + 1) ~/ 2,
                            itemBuilder: (context, i) {
                              final first = filtered[i * 2];
                              final second =
                                  i * 2 + 1 < filtered.length
                                      ? filtered[i * 2 + 1]
                                      : null;
                              return SizedBox(
                                width: _categoryColumnWidth + 12,
                                child: Column(
                                  children: [
                                    _buildRoundCategory(first),
                                    if (second != null) ...[
                                      const SizedBox(height: 12),
                                      _buildRoundCategory(second),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Рекомендовано вам',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                _recommendedLoading
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : _recommended.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              child: Text(
                                session.sellerPhone.trim().isEmpty
                                    ? 'Включите режим продавца в профиле — здесь появятся ваши объявления.'
                                    : 'Пока нет ваших объявлений.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.92,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, i) =>
                                    _buildRecommendedProductCard(_recommended[i]),
                                childCount: _recommended.length,
                              ),
                            ),
                          ),
              ],
            );
          },
        ),
      ),
    );
  }
}
