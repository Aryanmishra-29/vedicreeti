import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cache_service.dart';
class ProductRepository {
  static Future<List<Map<String, dynamic>>> fetchFeaturedProducts() async {
    final cached = await CacheService.loadCache('featured_products');
    _syncFeaturedProducts(); // Background sync
    if (cached != null && cached.isNotEmpty) {
      return List<Map<String, dynamic>>.from(cached);
    }
    return await _syncFeaturedProducts();
  }
  static Future<List<Map<String, dynamic>>> _syncFeaturedProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('is_active', true)
          .limit(5);
      final productsList = (response as List).whereType<Map<String, dynamic>>().toList();
      await CacheService.saveCache('featured_products', productsList);
      return productsList;
    } catch (e, stackTrace) {
      developer.log('Error syncing featured products', error: e, stackTrace: stackTrace, name: 'ProductRepository');
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    final cached = await CacheService.loadCache('all_products');
    _syncAllProducts(); // Background sync
    if (cached != null && cached.isNotEmpty) {
      return List<Map<String, dynamic>>.from(cached);
    }
    return await _syncAllProducts();
  }
  static Future<List<Map<String, dynamic>>> _syncAllProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at');
      final productsList = (response as List).whereType<Map<String, dynamic>>().toList();
      await CacheService.saveCache('all_products', productsList);
      return productsList;
    } catch (e, stackTrace) {
      developer.log('Error syncing all products', error: e, stackTrace: stackTrace, name: 'ProductRepository');
      return [];
    }
  }
}
