import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageAgroSig {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Guardar datos de usuario después del login/registro
  Future<void> persistUserData(String accessToken, String refreshToken, int userId) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId.toString());
  }

  // Obtener access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Obtener refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Obtener user ID
  Future<int?> getUserId() async {
    final idString = await _storage.read(key: 'user_id');
    return idString != null ? int.tryParse(idString) : null;
  }

  // Verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Limpiar todos los datos (logout)
  Future<void> clearAllData() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
  }
}

final secureStorage = SecureStorageAgroSig();