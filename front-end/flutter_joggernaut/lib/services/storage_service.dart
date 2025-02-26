import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future saveToken(String key,String token) async {
    await _storage.write(key: key, value: token);
  }

  Future getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  Future getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  Future deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Save data
  Future<void> saveData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Retrieve data
  Future<String?> getData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data
  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  // Clear everything (use for logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}