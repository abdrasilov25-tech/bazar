import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bazar/core/state/app_session.dart';
import 'package:bazar/features/products/product.dart';
import 'package:bazar/features/products/presentation/product_details_page.dart';

class SellTab extends StatefulWidget {
  const SellTab({super.key});

  @override
  State<SellTab> createState() => _SellTabState();
}

class _SellTabState extends State<SellTab> {
  final _supabase = Supabase.instance.client;

  bool _loading = false;
  String? _error;
  List<Product> _myAds = const [];

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Фрукты');
  final _mediaUrlController = TextEditingController();
  String _mediaType = 'image';
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMyAds();
  }

  Future<void> _loadMyAds() async {
    final session = context.read<AppSession>();
    if (!session.isSeller || session.sellerPhone.trim().isEmpty) {
      setState(() {
        _myAds = const [];
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
          .eq('seller_phone', session.sellerPhone)
          .order('created_at', ascending: false);

      final list = (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(Product.fromMap)
          .toList();

      if (!mounted) return;
      setState(() {
        _myAds = list;
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final contentType = (ext == 'png') ? 'image/png' : 'image/jpeg';

      final objectPath =
          'products/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';

      await _supabase.storage.from('product-media').uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final publicUrl = _supabase.storage
          .from('product-media')
          .getPublicUrl(objectPath)
          .trim();
      _mediaUrlController.text = publicUrl;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ошибка загрузки фото: $e\n"
            "Проверь bucket 'product-media' в Supabase Storage (лучше сделать public).",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _publish() async {
    final session = context.read<AppSession>();
    if (!session.isSeller || session.sellerPhone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Включите режим продавца в профиле')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();
    final category = _categoryController.text.trim();
    final mediaUrl = _mediaUrlController.text.trim();

    if (title.isEmpty || price <= 0 || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните название, цену и категорию')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final p = Product(
        id: '',
        title: title,
        price: price,
        description: description,
        category: category,
        mediaUrl: mediaUrl,
        mediaType: _mediaType,
        sellerPhone: session.sellerPhone,
      );

      await _supabase.from('products').insert(p.toInsertMap());

      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _mediaUrlController.clear();

      await _loadMyAds();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Объявление опубликовано')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();

    return Scaffold(
      appBar: AppBar(title: const Text('Продать')),
      body: RefreshIndicator(
        onRefresh: _loadMyAds,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Новое объявление',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Цена (тг)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Категория (например: Фрукты)',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Медиа:'),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _mediaType,
                          items: const [
                            DropdownMenuItem(value: 'image', child: Text('Фото')),
                            DropdownMenuItem(value: 'video', child: Text('Видео')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _mediaType = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_mediaType == 'image')
                      OutlinedButton.icon(
                        onPressed: _uploading ? null : _pickAndUploadImage,
                        icon: _uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.photo_library_outlined),
                        label: Text(_uploading ? 'Загрузка...' : 'Загрузить фото'),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _mediaUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на фото/видео (необязательно)',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _publish,
                      child: Text(
                        session.isSeller ? 'Опубликовать' : 'Включите продавца в профиле',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text('Ошибка: $_error',
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Мои объявления',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (!session.isSeller)
              const Text('Переключитесь на продавца, чтобы видеть свои объявления.')
            else if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_myAds.isEmpty)
              const Text('Пока нет объявлений.')
            else
              ..._myAds.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
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
                      child: ListTile(
                        title: Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('${p.price} тг'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

