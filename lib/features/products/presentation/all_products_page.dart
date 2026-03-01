import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/core/utils/whatsapp.dart';
import 'package:bazar/features/products/product.dart';
import 'package:bazar/features/products/presentation/product_details_page.dart';


class AllProductsPage extends StatefulWidget {
  final String categoryName;

  const AllProductsPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;
  List<Product> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rows = await _supabase
          .from('products')
          .select()
          .eq('category', widget.categoryName)
          .order('created_at', ascending: false);

      final list = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromMap)
          .toList();

      setState(() {
        _products = list;
        _isLoading = false;
      });
    } catch (e, s) {
      setState(() {
        _error = '$e\n$s';
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddProductBottomSheet() async {
    final session = context.read<AppSession>();
    if (!session.isSeller) return;

    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final mediaUrlController = TextEditingController();
    String mediaType = 'image';
    bool isUploading = false;

    Future<void> save(BuildContext ctx) async {
      final title = titleController.text.trim();
      final price = int.tryParse(priceController.text.trim()) ?? 0;
      final description = descriptionController.text.trim();
      final mediaUrl = mediaUrlController.text.trim();

      if (title.isEmpty || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите корректные название и цену')),
        );
        return;
      }
      if (session.sellerPhone.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не указан номер продавца в начале')),
        );
        return;
      }

      try {
        final product = Product(
          id: '',
          title: title,
          price: price,
          description: description,
          category: widget.categoryName,
          mediaUrl: mediaUrl,
          mediaType: mediaType,
          sellerPhone: session.sellerPhone,
        );

        await _supabase.from('products').insert(product.toInsertMap());

        if (!ctx.mounted) return;
        Navigator.of(ctx).pop();
        await _load();
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  'Добавить товар',
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Медиа:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: mediaType,
                      items: const [
                        DropdownMenuItem(value: 'image', child: Text('Фото')),
                        DropdownMenuItem(value: 'video', child: Text('Видео')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setModalState(() => mediaType = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (mediaType == 'image') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (picked == null) return;

                              setModalState(() => isUploading = true);
try {
  final bytes = await picked.readAsBytes();
  final ext = picked.name.split('.').last.toLowerCase();
  final contentType =
      (ext == 'png') ? 'image/png' : 'image/jpeg';

  final objectPath =
      'products/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

  // Загружаем бинарник в storage
  await _supabase.storage
      .from('product-media')
      .uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
        ),
      );

  // Публичный URL для отображения фото (bucket должен быть public + политики в supabase_setup.sql)
  final publicUrl = _supabase.storage
      .from('product-media')
      .getPublicUrl(objectPath)
      .trim();

  mediaUrlController.text = publicUrl;

  if (ctx.mounted) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Фото загружено'),
      ),
    );
  }
} catch (e) {
  if (ctx.mounted) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          "Ошибка загрузки фото: $e\n"
          "Проверь bucket 'product-media' в Supabase Storage (лучше сделать public).",
        ),
      ),
    );
  }
} finally {
  setModalState(() => isUploading = false);
}
                            },
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_library_outlined),
                      label: Text(isUploading ? 'Загрузка...' : 'Выбрать фото'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: mediaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Ссылка на фото/видео (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
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
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildMedia(Product p) {
  final url = p.mediaUrl.trim();
  final isImage = p.mediaType == 'image';
  final isVideo = p.mediaType == 'video';

  // Если URL пустой
  if (url.isEmpty) {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 40),
    );
  }

  // Если это изображение
  if (isImage) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.red),
        );
      },
    );
  }

  // Если это видео
  if (isVideo) {
    return InkWell(
      onTap: () => _openExternal(url),
      child: Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 48),
        ),
      ),
    );
  }

  return const SizedBox.shrink();
}

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: session.isSeller
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddProductBottomSheet,
                  tooltip: 'Добавить товар',
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 24),
                        SelectableText(
                          'Ошибка загрузки товаров:\n$_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        const SelectableText(
                          "Проверь, что в Supabase есть таблица 'products' с колонками:\n"
                          "title (text), price (int), description (text), category (text), "
                          "media_url (text), media_type (text), seller_phone (text), created_at (timestamp).",
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Повторить'),
                        ),
                      ],
                    )
                  : _products.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 24),
                            Center(child: Text('Нет товаров в этой категории')),
                          ],
                        )
                      : GridView.builder(
                          itemCount: _products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          itemBuilder: (context, index) {
                            final session = context.watch<AppSession>();
                            final p = _products[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailsPage(product: p),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            _buildMedia(p),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withAlpha(230),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  visualDensity: VisualDensity.compact,
                                                  iconSize: 20,
                                                  onPressed: () => context
                                                      .read<AppSession>()
                                                      .toggleFavorite(p.id),
                                                  icon: Icon(
                                                    session.isFavorite(p.id)
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: session.isFavorite(p.id)
                                                        ? Colors.red
                                                        : Colors.black45,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                        ),
                                      Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
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
                                          if (p.description.trim().isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              p.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: p.sellerPhone.trim().isEmpty
                                                  ? null
                                                  : () async {
                                                      try {
                                                        await openWhatsApp(
                                                          phone: p.sellerPhone,
                                                          text:
                                                              'Здравствуйте! Интересует товар: ${p.title} (${p.price} тг)',
                                                        );
                                                      } catch (e) {
                                                        if (!context.mounted) return;
                                                        ScaffoldMessenger.of(context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Не удалось открыть WhatsApp: $e'),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              child: const Text('WhatsApp'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}