import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:agrosig/domain/models/response/response_default.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../../../config/keys.dart';
import '../../../data/local_secure/secure_storage.dart';

class PlotServices {

  final SecureStorageAgroSig secureStorage = SecureStorageAgroSig();

  Future<ResponseDefault> registerParcel({
    required String name,
    required double lat,
    required double long,
    //required String ubicacion,
    required double superficie,
  }) async {

    try {
      final token = await secureStorage.getAccessToken();
      final refreshToken = await secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        return ResponseDefault(resp: false, msg: 'No authentication token found');
      }

      final ubicacion = '${lat.toString().replaceAll(' ', '')},${long.toString().replaceAll(' ', '')}';

      print('Datos enviados al backend:');
      print('Nombre: $name');
      print('Ubicación: $ubicacion');
      print('Superficie: $superficie');

      final uri = Uri.parse('${Environment.endpointApiAuth}/register-parcel');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'xx-token': token,
        },
        body: jsonEncode({
          'id_user': await secureStorage.getUserId(),
          'nombre': name,
          'ubicacion': ubicacion,
          'superficie': superficie.toString(),
        }),
      );

      print('Respuesta del backend: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return ResponseDefault.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        return ResponseDefault(
          resp: false,
          msg: errorData['msg'] ?? 'Error desconocido al registrar parcela',
        );
      }
    } catch (e) {
      print('Error al backend $e');
      return ResponseDefault(
        resp: false,
        msg: 'Error de conexión: ${e.toString()}',
      );
    }
  }
}

final plotServices = PlotServices();