import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

enum UserRole { buyer, seller }

class AppSession extends ChangeNotifier {
  static const _kRole = 'session.role';
  static const _kSellerPhone = 'session.sellerPhone';
  static const _kFavorites = 'session.favorites';
  static const _kCart = 'session.cart';

  final Completer<void> _readyCompleter = Completer();
  UserRole _role = UserRole.buyer;
  String _sellerPhone = '';
  final Set<String> _favorites = <String>{};
  final List<Map<String, dynamic>> _cart = <Map<String, dynamic>>[];

  Future<void> get ready => _readyCompleter.future;
  UserRole get role => _role;
  String get sellerPhone => _sellerPhone;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);

  bool get isSeller => _role == UserRole.seller;

  AppSession() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleStr = prefs.getString(_kRole);
      final phone = prefs.getString(_kSellerPhone) ?? '';
      final fav = prefs.getStringList(_kFavorites) ?? const <String>[];
      final cartJson = prefs.getStringList(_kCart) ?? const <String>[];

      _role = (roleStr == 'seller') ? UserRole.seller : UserRole.buyer;
      _sellerPhone = phone;
      _favorites
        ..clear()
        ..addAll(fav);

      _cart
        ..clear()
        ..addAll(cartJson.map(_decodeMap).whereType<Map<String, dynamic>>());
    } finally {
      _readyCompleter.complete();
      notifyListeners();
    }
  }

  void _persistLater() {
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, isSeller ? 'seller' : 'buyer');
    await prefs.setString(_kSellerPhone, _sellerPhone);
    await prefs.setStringList(_kFavorites, _favorites.toList());
    await prefs.setStringList(_kCart, _cart.map(_encodeMap).toList());
  }

  String _encodeMap(Map<String, dynamic> map) => jsonEncode(map);

  Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  void setBuyer() {
    _role = UserRole.buyer;
    _persistLater();
    notifyListeners();
  }

  void setSeller({required String phone}) {
    _role = UserRole.seller;
    _sellerPhone = phone;
    _persistLater();
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    _persistLater();
    notifyListeners();
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  void addToCart({
    required String productId,
    required String title,
    required int price,
    required String sellerPhone,
  }) {
    _cart.add({
      'product_id': productId,
      'title': title,
      'price': price,
      'seller_phone': sellerPhone,
      'qty': 1,
    });
    _persistLater();
    notifyListeners();
  }

  void removeFromCartAt(int index) {
    if (index < 0 || index >= _cart.length) return;
    _cart.removeAt(index);
    _persistLater();
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _persistLater();
    notifyListeners();
  }
}

