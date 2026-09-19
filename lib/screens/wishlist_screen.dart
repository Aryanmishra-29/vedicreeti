import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/product_card.dart';
import '../widgets/heart_button.dart';
import '../wishlist_service.dart';
import '../widgets/grid_product_skeleton_card.dart';
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}
class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  List<dynamic> _wishlistProducts = [];
  @override
  void initState() {
    super.initState();
    _fetchWishlistProducts();
  }
  Future<void> _fetchWishlistProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final likedIds = WishlistService.instance.likedProductIds.toList();
      if (likedIds.isEmpty) {
        setState(() {
          _wishlistProducts = [];
          _isLoading = false;
        });
        return;
      }
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .inFilter('id', likedIds)
          .eq('is_active', true);
      setState(() {
        _wishlistProducts = response;
              _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching wishlist products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Divine Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
            fontFamily: 'Serif',
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
        ),
      ),
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.52,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const GridProductSkeletonCard(),
            )
          : _wishlistProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Divine Wishlist is empty',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover sacred items to add to your collection.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.52,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final product = _wishlistProducts[index];
                    final productId = product['id']?.toString() ?? '';
                    return ProductCard(
                      product: product,
                      topTrailingAction: productId.isNotEmpty ? HeartButton(productId: productId) : null,
                    );
                  },
                ),
    );
  }
}
