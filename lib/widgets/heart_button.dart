import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_bottom_sheet.dart';
import '../wishlist_service.dart';
class HeartButton extends StatelessWidget {
  final String productId;
  const HeartButton({super.key, required this.productId});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WishlistService.instance,
      builder: (context, child) {
        final isLiked = WishlistService.instance.isLiked(productId);
        return GestureDetector(
          onTap: () async {
            final currentUser = Supabase.instance.client.auth.currentUser;
            if (currentUser == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF1A1A1A),
                    content: const Text(
                      'Please login to add items to your wishlist.',
                      style: TextStyle(color: Colors.white),
                    ),
                    action: SnackBarAction(
                      label: 'Login',
                      textColor: const Color(0xFFF97316),
                      onPressed: () {
                        AuthBottomSheet.show(context);
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              return;
            }
            final success = await WishlistService.instance.toggleWishlist(productId);
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update wishlist. Please check your connection.', style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFF1A1A1A),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isLiked),
              color: isLiked ? const Color(0xFFD4AF37) : Colors.white, // Gold when liked, white when unliked
              size: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
