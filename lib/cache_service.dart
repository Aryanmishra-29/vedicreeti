import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';
class CacheService {
  static const String boxName = 'coreCache';
  static Future<void> saveCache(String key, List<dynamic> data) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.put(key, data);
      developer.log('Successfully saved cache for key: $key', name: 'CacheService');
    } catch (e, stackTrace) {
      developer.log('Error saving cache for $key', name: 'CacheService', error: e, stackTrace: stackTrace);
    }
  }
  static Future<List<dynamic>?> loadCache(String key) async {
    try {
      final box = await Hive.openBox(boxName);
      final dynamic data = box.get(key);
      if (data != null) {
        final parsed = List<dynamic>.from(data.map((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          }
          return e;
        }));
        if (parsed.isEmpty) {
          developer.log('Cache is empty for key: $key, ignoring it', name: 'CacheService');
          return null; // Ignore empty cache
        }
        developer.log('Successfully loaded cache for key: $key', name: 'CacheService');
        return parsed;
      }
    } catch (e, stackTrace) {
      developer.log('Error loading cache for $key', name: 'CacheService', error: e, stackTrace: stackTrace);
    }
    return null;
  }
}
