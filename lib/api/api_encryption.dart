import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  // Strong 32-character key with mixed characters
  static const String _KEY = 'Kj#9mPt5vN2xR7tL@4hB8cQ1wZ3yE6sA';

  // Strong 16-character IV
  static const String _IV = 'Uh#5mKE9vB2xP4tN';

  static const bool _encryptionEnabled = false;

  // Create encryption instance
  static final _key = Key.fromUtf8(_KEY);
  static final _iv = IV.fromUtf8(_IV);
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static Future<bool> isEncryptionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('encryption_enabled') ?? _encryptionEnabled;
  }

  // Encrypt entire request body
  static String encryptRequest(Map<String, dynamic> data) {
    if (!_encryptionEnabled) return json.encode(data);
    try {
      final jsonString = json.encode(data);
      final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return json.encode(data);
    }
  }

  // Decrypt entire response body
  static String decryptResponse(String encryptedData) {
    if (!_encryptionEnabled) return encryptedData;
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      print('Decryption error: $e');
      return encryptedData;
    }
  }

  // For URL parameters encryption
  static String encryptUrlParam(String param) {
    if (!_encryptionEnabled) return param;
    try {
      final encrypted = _encrypter.encrypt(param, iv: _iv);
      // Make the encrypted string URL-safe
      return Uri.encodeComponent(encrypted.base64);
    } catch (e) {
      print('URL param encryption error: $e');
      return param;
    }
  }

  // Helper method to test encryption
  static bool testEncryption() {
    try {
      const testString = "Test encryption";
      final encrypted = encryptRequest({"test": testString});
      final decrypted = decryptResponse(encrypted);
      final decoded = json.decode(decrypted);
      return decoded["test"] == testString;
    } catch (e) {
      print('Encryption test failed: $e');
      return false;
    }
  }
}