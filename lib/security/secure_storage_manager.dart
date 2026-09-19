import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class SecurityManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  static Future<void> saveSensitiveData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  static Future<String?> getSensitiveData(String key) async {
    return await _storage.read(key: key);
  }
  static Future<void> deleteSensitiveData(String key) async {
    await _storage.delete(key: key);
  }
  static Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
