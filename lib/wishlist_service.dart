import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class WishlistService extends ChangeNotifier {
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal() {
    _init();
  }
  final Set<String> _likedProductIds = {};
  bool _isInitialized = false;
  Set<String> get likedProductIds => _likedProductIds;
  bool get isInitialized => _isInitialized;
  void _init() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchWishlist();
      } else {
        _likedProductIds.clear();
        notifyListeners();
      }
    });
  }
  Future<void> fetchWishlist() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final response = await Supabase.instance.client
          .from('user_wishlist')
          .select('product_id')
          .eq('user_id', user.id);
      _likedProductIds.clear();
      for (final row in response) {
        if (row['product_id'] != null) {
          _likedProductIds.add(row['product_id'].toString());
        }
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    }
  }
  bool isLiked(String productId) {
    return _likedProductIds.contains(productId);
  }
  Future<bool> toggleWishlist(String productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('Cannot toggle wishlist: User not logged in.');
      return false;
    }
    final currentlyLiked = isLiked(productId);
    if (currentlyLiked) {
      _likedProductIds.remove(productId);
    } else {
      _likedProductIds.add(productId);
    }
    notifyListeners();
    try {
      if (currentlyLiked) {
        await Supabase.instance.client
            .from('user_wishlist')
            .delete()
            .match({'user_id': user.id, 'product_id': productId});
      } else {
        await Supabase.instance.client
            .from('user_wishlist')
            .insert({'user_id': user.id, 'product_id': productId});
        try {
          final taskResponse = await Supabase.instance.client
              .from('user_completed_tasks')
              .select('id')
              .match({'user_id': user.id, 'task_id': 'task_wishlist'})
              .maybeSingle();
          if (taskResponse == null) {
            await Supabase.instance.client.from('user_completed_tasks').insert({
              'user_id': user.id,
              'task_id': 'task_wishlist',
            });
            final currentMeta = Map<String, dynamic>.from(user.userMetadata ?? {});
            final currentKarma = (currentMeta['karma_points'] as num?)?.toInt() ?? 0;
            currentMeta['karma_points'] = currentKarma + 20;
            await Supabase.instance.client.auth.updateUser(UserAttributes(data: currentMeta));
            debugPrint('Awarded 20 Karma points for Wishlist Quest!');
          }
        } catch (karmaError) {
          debugPrint('Error awarding Karma for wishlist: $karmaError');
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling wishlist in database: $e');
      if (currentlyLiked) {
        _likedProductIds.add(productId);
      } else {
        _likedProductIds.remove(productId);
      }
      notifyListeners();
      return false;
    }
  }
}
