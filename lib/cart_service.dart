import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CartItem {
  final String id;
  final dynamic name;
  final double price;
  final String? imageUrl;
  int quantity;
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
class CartService extends ChangeNotifier {
  static final CartService instance = CartService._internal();
  CartService._internal() {
    _loadCart();
  }
  List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_data');
    if (cartString != null) {
      try {
        final List<dynamic> decoded = json.decode(cartString);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading cart: $e');
      }
    }
  }
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_data', encoded);
    notifyListeners();
  }
  void addItem(dynamic product) {
    final id = product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final dynamic name = product['title'] ?? product['name'] ?? 'Product';
    final dynamic rawPrice = product['sale_price'] ?? product['price'] ?? 0;
    final double price = rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice.toString()) ?? 0.0;
    String? imageUrl;
    final imgs = product['images'];
    if (imgs is List && imgs.isNotEmpty) {
      imageUrl = imgs[0].toString();
    } else if (imgs is String && imgs.isNotEmpty) {
      imageUrl = imgs;
    } else if (product['image_url'] != null) {
      imageUrl = product['image_url'].toString();
    }
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
      ));
    }
    _saveCart();
  }
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
  }
  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCart();
    }
  }
  void clearCart() {
    _items.clear();
    _saveCart();
  }
}
