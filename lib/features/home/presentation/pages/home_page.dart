import 'package:bazar/features/home/domain/entites/market_category.dart';
import 'package:bazar/features/products/product.dart';
import 'package:bazar/features/products/presentation/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/home/presentation/cubit/market_cubit.dart';
import 'package:bazar/core/localization/app_localizations.dart';

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
    if (_loadedRecommendedPhone != 'loaded') {
      _loadedRecommendedPhone = 'loaded';
      _loadRecommended();
    }
  }

  Future<void> _loadRecommended() async {
    if (!mounted) return;
    setState(() => _recommendedLoading = true);
    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select()
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

  Future<void> _showEditProductBottomSheet(Product existing) async {
    final session = context.read<AppSession>();
    if (!session.isSeller || existing.sellerPhone.trim() != session.sellerPhone.trim()) {
      return;
    }

    final titleController = TextEditingController(text: existing.title);
    final priceController = TextEditingController(text: existing.price.toString());
    final descriptionController = TextEditingController(text: existing.description);

    Future<void> save(BuildContext ctx) async {
      final title = titleController.text.trim();
      final price = int.tryParse(priceController.text.trim()) ?? 0;
      final description = descriptionController.text.trim();

      if (title.isEmpty || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите корректные название и цену')),
        );
        return;
      }

      try {
        final id = int.tryParse(existing.id) ?? existing.id;
        await Supabase.instance.client.from('products').update({
          'title': title,
          'price': price,
          'description': description,
        }).eq('id', id);

        if (!ctx.mounted) return;
        Navigator.of(ctx).pop();
        await _loadRecommended();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар обновлён')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Редактировать товар',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Цена (тг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => save(ctx),
                  child: const Text('Сохранить'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product p) async {
    final session = context.read<AppSession>();
    if (!session.isSeller || p.sellerPhone.trim() != session.sellerPhone.trim()) {
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить товар'),
            content: Text('Вы уверены, что хотите удалить "${p.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      final id = int.tryParse(p.id) ?? p.id;
      await Supabase.instance.client.from('products').delete().eq('id', id);
      if (!mounted) return;
      setState(() {
        _recommended = _recommended.where((it) => it.id != p.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар удалён')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

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
    final isOwner =
        session.isSeller && p.sellerPhone.trim() == session.sellerPhone.trim();
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOwner)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditProductBottomSheet(p);
                                } else if (value == 'delete') {
                                  _deleteProduct(p);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Редактировать'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Удалить'),
                                ),
                              ],
                            ),
                          ),
                        GestureDetector(
                          onTap: () =>
                              context.read<AppSession>().toggleFavorite(p.id),
                          child: Icon(
                            session.isFavorite(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: session.isFavorite(p.id)
                                ? Colors.red
                                : Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('app.title')),
        actions: [
          if (session.isSeller) ...[
            IconButton(
              tooltip: 'Обновить мои товары',
              icon: const Icon(Icons.refresh),
              onPressed: _recommendedLoading ? null : _loadRecommended,
            ),
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
                    loc.t('role.seller'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    loc.t('role.buyer'),
                    style: const TextStyle(
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
                          decoration: InputDecoration(
                            hintText: loc.t('home.search'),
                            prefixIcon: const Icon(Icons.search_outlined),
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
                                  loc.t('home.banner'),
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
                          loc.t('home.categories'),
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
                      loc.t('home.recommended'),
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
                                loc.t('home.recommended.empty.noAds'),
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
