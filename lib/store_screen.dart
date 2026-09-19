import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}
class _StoreScreenState extends State<StoreScreen> {
  final List<String> _categories = [
    'All',
    'Rudraksha',
    'Yantras',
    'Gemstones',
    'Puja Samagri',
  ];
  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _products = [
    {
      'title': '5 Mukhi Siddha Rudraksha',
      'price': '₹1,100',
      'image': 'assets/images/rudraksha.png', // Placeholder path
    },
    {
      'title': 'Shree Yantra (Brass)',
      'price': '₹2,500',
      'image': 'assets/images/yantra.png',
    },
    {
      'title': 'Sphatik Crystal Mala',
      'price': '₹1,800',
      'image': 'assets/images/mala.png',
    },
    {
      'title': 'Premium Puja Thali',
      'price': '₹3,200',
      'image': 'assets/images/thali.png',
    },
    {
      'title': 'Yellow Sapphire (Pukhraj)',
      'price': '₹15,000',
      'image': 'assets/images/sapphire.png',
    },
    {
      'title': 'Gomati Chakra (Set of 11)',
      'price': '₹450',
      'image': 'assets/images/chakra.png',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildCategoryChips(),
          const SizedBox(height: 24),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'वैदिक ई-स्टोर', // Vedic E-Store
        style: TextStyle(
          color: Color(0xFF2A241D),
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Serif',
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF2A241D),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8520A), // Saffron badge
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Color(0xFF2A241D)),
    );
  }
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC9A227).withOpacity(0.15)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFC9A227)
                            : const Color(0xFFE7D8B1),
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2A241D)
                            : const Color(0xFF6B6258),
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontFamily: 'Serif',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildProductGrid() {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product);
      },
    );
  }
  Widget _buildProductCard(Map<String, dynamic> product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              splashColor: const Color(
                0xFFC9922A,
              ).withOpacity(0.15), // Gold splash
              highlightColor: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A0A0C),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Serif',
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product['price'],
                          style: const TextStyle(
                            color: Color(0xFFC9A227),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFDF00), Color(0xFFD4AF37)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Color(0xFF121212),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Color(0xFF121212),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Serif',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
