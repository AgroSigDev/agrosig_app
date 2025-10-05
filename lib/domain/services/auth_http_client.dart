import 'dart:convert';
import 'package:http/http.dart';
import '../../data/local_secure/secure_storage.dart';

class AuthHttpClient {
  final SecureStorageAgroSig secureStorage = SecureStorageAgroSig();
  final Client _client = Client();
  final String baseUrl;

  AuthHttpClient(this.baseUrl);

  Future<Response> get(String endpoint, {Map<String, String>? headers}) async {
    return _sendRequest(
          () async => await _client.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _buildHeaders(headers),
      ),
    );
  }

  Future<Response> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
          () async => await _client.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _buildHeaders(headers),
        body: body,
      ),
    );
  }

  Future<Response> put(String endpoint, {Map<String, String>? headers, Object? body}) async {
    return _sendRequest(
          () async => await _client.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _buildHeaders(headers),
        body: body,
      ),
    );
  }

  Future<Response> delete(String endpoint, {Map<String, String>? headers}) async {
    return _sendRequest(
          () async => await _client.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _buildHeaders(headers),
      ),
    );
  }

  Future<MultipartRequest> multipartRequest(String method, String endpoint) async {
    final request = MultipartRequest(
        method,
        Uri.parse('$baseUrl/$endpoint')
    );
    request.headers.addAll(await _buildHeaders());
    return request;
  }

  Future<Map<String, String>> _buildHeaders([Map<String, String>? additionalHeaders]) async {
    final token = await secureStorage.getAccessToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['xx-token'] = token;
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Future<Response> _sendRequest(Future<Response> Function() request) async {
    try {
      // Primera solicitud
      Response response = await request();

      // Si el token es inválido o expiró (código 401)
      if (response.statusCode == 401) {
        final newToken = await _refreshToken();

        if (newToken != null) {
          // Reintentar la solicitud con el nuevo token
          response = await request();
        } else {
          // No se pudo refrescar el token, hacer logout
          await _logout();
          throw Exception('Session expired. Please login again.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _client.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Accept': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        final idUser = await secureStorage.getUserId();

        if (idUser != null) {
          await secureStorage.persistUserData(
            newAccessToken,
            newRefreshToken,
            idUser,
          );
        }

        return newAccessToken;
      } else {
        await _logout();
        return null;
      }
    } catch (e) {
      await _logout();
      return null;
    }
  }

  Future<void> _logout() async {
    final idUser = await secureStorage.getUserId();
    if (idUser != null) {
      try {
        await post('logout', body: jsonEncode({
          'id_user': idUser,
          'refresh_token': await secureStorage.getRefreshToken(),
        }));
      } catch (e) {
        // Ignorar errores de logout ya que estamos limpiando la sesión de todos modos
      }
    }
    await secureStorage.clearAllData();
    // Aquí podrías redirigir al login screen usando Get.offAll(() => SignInScreen());
  }

  void close() {
    _client.close();
  }
}