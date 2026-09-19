import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cart_service.dart';
import 'cart_screen.dart';
import '../widgets/add_review_sheet.dart';
import '../widgets/heart_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/localization_helper.dart';
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _product;
  int _selectedImageIndex = 0;
  int _selectedQuantity = 1;
  bool _isDescriptionExpanded = false;
  List<Map<String, dynamic>> _reviews = [];
  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }
  Future<void> _fetchProductDetails() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('id', widget.productId)
          .single();
      final reviewsResponse = await Supabase.instance.client
          .from('product_reviews_with_profiles')
          .select('*')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _product = response;
          _reviews = List<Map<String, dynamic>>.from(reviewsResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  String _getDiscountPercentage(num mrp, num salePrice) {
    if (mrp <= 0 || salePrice >= mrp) return '0%';
    double discount = ((mrp - salePrice) / mrp) * 100;
    return '-${discount.toStringAsFixed(0)}%';
  }
  List<String> _getImages() {
    if (_product == null) return [];
    var imgs = _product!['images'];
    if (imgs is List) {
      return imgs.map((e) => e.toString()).toList();
    } else if (imgs is String) {
      return [imgs];
    } else if (_product!['image_url'] != null) {
      return [_product!['image_url'].toString()];
    }
    return [];
  }
  void _incrementQuantity(int stock) {
    int maxAllowed = stock < 10 ? stock : 10;
    if (_selectedQuantity < maxAllowed) {
      setState(() {
        _selectedQuantity++;
      });
    }
  }
  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() {
        _selectedQuantity--;
      });
    }
  }
  void _addToCart({bool navigateToCart = false}) {
    if (_product != null) {
      final productToAdd = Map<String, dynamic>.from(_product!);
      productToAdd['selected_quantity'] = _selectedQuantity;
      if (navigateToCart) {
        final rawPrice = _product!['sale_price'] ?? _product!['price'] ?? 0;
        final double price = rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice.toString()) ?? 0.0;
        String title = getLocalizedText(_product!['title'] ?? _product!['name'], context.locale.languageCode);
        if (title.isEmpty) title = 'Product';
        String? imageUrl;
        final imgs = _product!['images'];
        if (imgs is List && imgs.isNotEmpty) {
          imageUrl = imgs[0].toString();
        } else if (imgs is String && imgs.isNotEmpty) {
          imageUrl = imgs;
        } else if (_product!['image_url'] != null) {
          imageUrl = _product!['image_url'].toString();
        }
        final directItem = CartItem(
          id: widget.productId,
          name: title,
          price: price,
          imageUrl: imageUrl,
          quantity: _selectedQuantity,
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(directPurchaseItem: directItem)));
      } else {
        CartService.instance.addItem(productToAdd);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${getLocalizedText(productToAdd['title'] ?? productToAdd['name'], context.locale.languageCode).isEmpty ? 'Product' : getLocalizedText(productToAdd['title'] ?? productToAdd['name'], context.locale.languageCode)} added to cart!'),
            backgroundColor: const Color(0xFF007600),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bgColor, // Clean, dynamic e-commerce background
      appBar: AppBar(
        title: const Text(''), // Clean empty appbar per standard premium e-com
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          HeartButton(productId: widget.productId),
          ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, child) {
              final itemCount = CartService.instance.itemCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).iconTheme.color),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFCC0C39),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _product == null
              ? _buildErrorState()
              : _buildProductDetails(),
    );
  }
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFFFFA41C)));
  }
  Widget _buildErrorState() {
    return Center(
      child: Text(
        'Product not found or an error occurred.',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
      ),
    );
  }
  Widget _buildProductDetails() {
    final images = _getImages();
    String title = getLocalizedText(_product!['title'] ?? _product!['name'], context.locale.languageCode);
    if (title.isEmpty) title = 'Premium Product';
    final num mrpPrice = _product!['mrp_price'] != null
        ? (_product!['mrp_price'] is num ? _product!['mrp_price'] : num.tryParse(_product!['mrp_price'].toString()) ?? 0)
        : (_product!['price'] is num ? _product!['price'] : num.tryParse(_product!['price']?.toString() ?? '0') ?? 0);
    final num salePrice = _product!['sale_price'] != null
        ? (_product!['sale_price'] is num ? _product!['sale_price'] : num.tryParse(_product!['sale_price'].toString()) ?? 0)
        : (_product!['price'] is num ? _product!['price'] : num.tryParse(_product!['price']?.toString() ?? '0') ?? 0);
    final int stockQuantity = _product!['stock_quantity'] != null
        ? (_product!['stock_quantity'] is int ? _product!['stock_quantity'] : int.tryParse(_product!['stock_quantity'].toString()) ?? 0)
        : 0;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 400,
                width: double.infinity,
                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor,
                child: images.isNotEmpty
                    ? _buildSafeNetworkImage(images[_selectedImageIndex], fit: BoxFit.cover)
                    : const Icon(Icons.spa_rounded, size: 100, color: Colors.deepOrange),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor).withOpacity(0.0),
                        (Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (images.length > 1)
            Container(
              color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor,
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF007185) : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFFFAFAFA) : Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildSafeNetworkImage(images[index], fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  final totalPurchases = _product!['total_purchases'] ?? 0;
                  final totalReviews = _product!['total_reviews'] ?? 0;
                  final avgRating = _product!['average_rating'] != null ? (_product!['average_rating'] as num).toDouble() : 5.0;
                  final adminOverride = _product!['admin_override_rating'];
                  final finalDisplayRating = adminOverride != null
                      ? (adminOverride as num).toDouble()
                      : (totalReviews == 0 ? 5.0 : avgRating);
                  return Row(
                    children: [
                      _buildStarRating(finalDisplayRating),
                      const SizedBox(width: 8),
                      Text(
                        '$totalReviews ratings',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF007185), // Amazon link color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $totalPurchases bought past month',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (mrpPrice > salePrice)
                      Text(
                        _getDiscountPercentage(mrpPrice, salePrice),
                        style: const TextStyle(
                          fontSize: 32, // HUGE
                          color: Color(0xFFF97316), // Vibrant Saffron
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (mrpPrice > salePrice) const SizedBox(width: 12),
                    Text(
                      '₹',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A1A1A) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      salePrice.toStringAsFixed(0),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38, // HUGE
                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF1A1A1A) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (mrpPrice > salePrice)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Text(
                          'M.R.P.: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${mrpPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: stockQuantity <= 0 ? null : () => _addToCart(navigateToCart: false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Transparent background
                      foregroundColor: const Color(0xFFF97316), // Saffron text
                      side: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: GestureDetector(
                    onTap: stockQuantity <= 0 ? null : () => _addToCart(navigateToCart: true),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: stockQuantity <= 0 ? null : const LinearGradient(
                          colors: [Color(0xFFF97316), Color(0xFFE65C00)], // Saffron to Burnt Orange
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        color: stockQuantity <= 0 ? Colors.grey.shade400 : null,
                        borderRadius: BorderRadius.circular(25), // Stadium look
                        boxShadow: stockQuantity > 0 && Theme.of(context).brightness == Brightness.light
                            ? [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ui.buy_now'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTrustBadge(Icons.security, 'Secure\nCheckout'),
                    _buildTrustBadge(Icons.science, 'Lab\nCertified'),
                    _buildTrustBadge(Icons.eco, 'Direct from\nNepal'),
                  ],
                ),
                const SizedBox(height: 24),
                () {
                  if (stockQuantity > 0 && stockQuantity < 5) {
                    if (kDebugMode) print('DEBUG [ProductDetail]: Scarcity Badge triggered for $title (Stock: $stockQuantity)');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Only $stockQuantity left in stock - order soon.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFCC0C39),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }(),
                Row(
                  children: [
                    if (stockQuantity > 0)
                      const Padding(
                        padding: EdgeInsets.only(right: 6.0),
                        child: Icon(Icons.circle, size: 10, color: Color(0xFF0F766E)),
                      ),
                    Text(
                      stockQuantity > 0 ? 'ui.in_stock'.tr() : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 18,
                        color: stockQuantity > 0 ? const Color(0xFF0F766E) : const Color(0xFFCC0C39),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stockQuantity > 0)
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _decrementQuantity,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Icon(Icons.remove, size: 18, color: Theme.of(context).iconTheme.color),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                '$_selectedQuantity',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            InkWell(
                              onTap: () => _incrementQuantity(stockQuantity),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Icon(Icons.add, size: 18, color: Theme.of(context).iconTheme.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    String descText = getLocalizedText(_product!['description'], context.locale.languageCode).trim();
                    if (descText.isEmpty) descText = 'Premium Vedic collection piece.';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                descText,
                                maxLines: _isDescriptionExpanded ? null : 4,
                                overflow: _isDescriptionExpanded ? null : TextOverflow.fade,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.5,
                                ),
                              ),
                              if (descText.length > 120)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded = !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isDescriptionExpanded ? 'Read Less' : 'Read More',
                                          style: const TextStyle(
                                            color: Color(0xFF007185), // Premium Teal link color
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF007185),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 32),
                Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (_reviews.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1A1A)
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 56,
                          color: const Color(0xFFF97316).withOpacity(0.8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Share Your Experience',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Be the first to bless this item with your thoughts and help others on their spiritual journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C00), Color(0xFFE65C00)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8C00).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => AddReviewSheet(productId: widget.productId),
                              );
                              if (result == true) {
                                _fetchProductDetails();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                            label: const Text(
                              'Write the First Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        separatorBuilder: (_, _) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          final rating = review['rating'] ?? 5;
                          final comment = review['comment'] ?? '';
                          final imageUrl = review['image_url'];
                          final userName = review['full_name'] ?? 'VedicReeti Customer';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFFF0F2F2),
                                    radius: 16,
                                    child: Icon(Icons.person, color: Colors.grey.shade500, size: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(userName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    starIdx < rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              if (comment.isNotEmpty)
                                Text(comment, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
                              if (imageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildSafeNetworkImage(imageUrl.toString(), fit: BoxFit.cover),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => AddReviewSheet(productId: widget.productId),
                            );
                            if (result == true) {
                              _fetchProductDetails();
                            }
                          },
                          icon: const Icon(Icons.edit, color: Color(0xFF007185)),
                          label: const Text('Write a Review', style: TextStyle(color: Color(0xFF007185), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF007185)),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  Widget _buildTrustBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF97316), size: 28), // Saffron/Gold
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade600 : Colors.white54,
          ),
        ),
      ],
    );
  }
  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
  Widget _buildSafeNetworkImage(String url, {BoxFit fit = BoxFit.contain}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        highlightColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF424242) : Colors.grey.shade50,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image, color: Colors.black12, size: 50),
      ),
    );
  }
}
