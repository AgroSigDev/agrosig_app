import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../config/keys.dart';
import '../../data/local_secure/secure_storage.dart';
import '../models/response/response_default.dart';
import '../models/response/response_login.dart';
import '../models/response/response_user_update.dart';
import '../models/user/user_model.dart';
import 'auth_http_client.dart';

class UserServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  // ========== REGISTER ==========
  Future<ResponseDefault> registerUser(
      String firstName,
      String paternalSurname,
      String maternalSurname,
      String? imagePath,
      String email,
      String password,
      ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Environment.endpointApiAuth}/register'),
      );

      // Campos que espera tu backend
      request.fields['first_name'] = firstName;
      request.fields['paternal_surname'] = paternalSurname;
      request.fields['maternal_surname'] = maternalSurname;
      request.fields['email'] = email;
      request.fields['password'] = password;

      // Imagen opcional
      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_user',
            imagePath,
          ),
        );
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print('Register Status: ${response.statusCode}');
      print('Register Response: ${responseData.body}');

      if (response.statusCode == 201) {
        final decodedData = jsonDecode(responseData.body);

        return ResponseDefault(
          resp: true,
          msg: decodedData['message'] ?? 'Usuario registrado exitosamente',
        );
      } else {
        final errorData = jsonDecode(responseData.body);
        return ResponseDefault(
          resp: false,
          msg: errorData['message'] ?? 'Error en el registro',
        );
      }
    } on SocketException {
      return ResponseDefault(
        resp: false,
        msg: 'Error de conexión: No hay internet',
      );
    } catch (e) {
      print('Register error: $e');
      return ResponseDefault(
        resp: false,
        msg: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  // ========== LOGIN ==========
  Future<ResponseLogin> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.endpointApiAuth}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final responseLogin = ResponseLogin.fromJson(decodedData);

        if (responseLogin.token.isNotEmpty) {
          // Decodificar el token para obtener el user_id
          final tokenData = _decodeToken(responseLogin.token);
          final userId = tokenData['user_id'];

          if (userId != null) {
            await _secureStorage.persistUserData(
              responseLogin.token,
              responseLogin.refreshToken,
              userId,
            );
          }
        }

        return responseLogin;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el login');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Error en el login: ${e.toString()}');
    }
  }

  // ========== DECODE JWT TOKEN ==========
  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token inválido');
      }

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded);
    } catch (e) {
      print('Error decoding token: $e');
      return {};
    }
  }

  // ========== GET USER PROFILE ==========
  Future<User> getUserProfile() async {
    try {
      final token = await _secureStorage.getAccessToken();

      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.get(
        Uri.parse('${Environment.endpointApiAuth}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          // O si tu backend usa 'xx-token'
          'xx-token': token,
        },
      );

      print('Get Profile Status: ${response.statusCode}');
      print('Get Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return User.fromJson(decodedData['data'] ?? decodedData);
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refresh
        final newToken = await refreshAccessToken();
        if (newToken != null) {
          return getUserProfile(); // Reintentar con nuevo token
        } else {
          await _secureStorage.clearAllData();
          throw Exception('Sesión expirada');
        }
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      print('Get profile error: $e');
      rethrow;
    }
  }

  // ========== REFRESH TOKEN ==========
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      final userId = await _secureStorage.getUserId();

      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('${Environment.endpointApiAuth}/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final newAccessToken = decodedData['accessToken'];
        final newRefreshToken = decodedData['refreshToken'];

        if (userId != null && newAccessToken != null) {
          await _secureStorage.persistUserData(
            newAccessToken,
            newRefreshToken ?? refreshToken, // Si no viene nuevo refresh, mantener el actual
            userId,
          );
        }

        return newAccessToken;
      } else {
        await _secureStorage.clearAllData();
        return null;
      }
    } catch (e) {
      await _secureStorage.clearAllData();
      return null;
    }
  }

  // ========== VERIFY TOKEN VALIDITY ==========
  Future<bool> verifyTokenValidity() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null) return false;

      // Decodificar el token para verificar expiración
      final tokenData = _decodeToken(token);
      final exp = tokenData['exp'] * 1000; // Convertir a milliseconds
      final now = DateTime.now().millisecondsSinceEpoch;

      // Si el token expira en menos de 5 minutos, considerarlo inválido
      if (exp - now < 5 * 60 * 1000) {
        // Intentar refresh
        final newToken = await refreshAccessToken();
        return newToken != null;
      }

      return true;
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      // Opcional: notificar al backend del logout
      if (token != null) {
        await http.post(
          Uri.parse('${Environment.endpointApiAuth}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'refreshToken': refreshToken,
          }),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Siempre limpiar datos locales
      await _secureStorage.clearAllData();
    }
  }
}

final userServices = UserServices();