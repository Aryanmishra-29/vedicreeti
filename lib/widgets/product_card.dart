import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cart_service.dart';
import '../utils/localization_helper.dart';
import '../screens/cart_screen.dart';
import '../screens/product_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final Widget? topTrailingAction; // E.g. HeartButton
  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onBuyNow,
    this.topTrailingAction,
  });
  void _defaultAddToCart(BuildContext context, {bool navigateToCart = false}) {
    if (navigateToCart) {
      final id = product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      String title = getLocalizedText(product['title'] ?? product['name'], context.locale.languageCode);
      if (title.isEmpty) title = 'Product';
      final rawPrice = product['sale_price'] ?? product['price'] ?? 0;
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
      final directItem = CartItem(
        id: id,
        name: title,
        price: price,
        imageUrl: imageUrl,
        quantity: 1,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CartScreen(directPurchaseItem: directItem)),
      );
    } else {
      CartService.instance.addItem(product);
      String title = getLocalizedText(product['name'], context.locale.languageCode);
      if (title.isEmpty) title = 'Product';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Widget _buildLuxuryFallback(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.diamond_outlined,
            size: 45,
            color: Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    String title = getLocalizedText(product['name'], context.locale.languageCode);
    if (title.isEmpty) title = 'Product';
    final num price = product['sale_price'] ?? product['price'] ?? 0;
    final int stock = product['stock_quantity'] ?? 0;
    String? imageUrl;
    final imgs = product['images'];
    if (imgs is List && imgs.isNotEmpty) {
      imageUrl = imgs[0].toString();
    } else if (imgs is String && imgs.isNotEmpty) {
      imageUrl = imgs;
    } else if (product['image_url'] != null) {
      imageUrl = product['image_url'].toString();
    }
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = Supabase.instance.client.storage.from('products').getPublicUrl(imageUrl);
    }
    return GestureDetector(
      onTap: () {
        final productId = product['id']?.toString();
        if (productId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: productId),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF151515) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFFE7D8B1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF151515) : const Color(0xFFFFFFFF),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                              highlightColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF424242) : Colors.grey.shade50,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => _buildLuxuryFallback(context),
                          )
                        : _buildLuxuryFallback(context),
                  ),
                  if (topTrailingAction != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: topTrailingAction!,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
                      fontFamily: 'Serif',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
                    ),
                  ),
                  (() {
                    if (stock > 0 && stock < 5) {
                      if (kDebugMode) print('DEBUG [ProductCard]: Scarcity Badge triggered for $title (Stock: $stock)');
                      return Text(
                        'Only $stock left in stock - order soon.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCC0C39),
                        ),
                      );
                    } else {
                      return Text(
                        stock > 0 ? '$stock ${'ui.in_stock'.tr()}' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: stock > 0
                              ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6258))
                              : Colors.redAccent,
                        ),
                      );
                    }
                  })(),
                  const SizedBox(height: 4),
                  OverflowBar(
                    spacing: 8.0,
                    overflowSpacing: 8.0,
                    children: [
                      SizedBox(
                        width: 48,
                        child: OutlinedButton(
                          onPressed: stock > 0 ? (onAddToCart ?? () => _defaultAddToCart(context, navigateToCart: false)) : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC9A227),
                            side: const BorderSide(color: Color(0xFFE7D8B1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.add_shopping_cart, size: 18),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC9A227), Color(0xFFE7D8B1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: stock > 0 ? (onBuyNow ?? () => _defaultAddToCart(context, navigateToCart: true)) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          ),
                          child: Text('ui.buy_now'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
