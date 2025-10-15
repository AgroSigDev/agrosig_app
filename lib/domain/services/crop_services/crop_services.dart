import 'dart:convert';
import 'dart:io';
import 'package:agrosig/config/keys.dart';
import 'package:agrosig/data/local_secure/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:agrosig/domain/models/crop/crop_model.dart';
import '../../response/response_crop/response_crop.dart';

class CropService {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  // Crear nuevo cultivo
  Future<CropResponse> registerCrop(Crop crop) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Environment.crop}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode(crop.toCreateJson()), // CORREGIDO: sin llaves extras
      );

      print('Crop Status: ${response.statusCode}');
      print('Crop Response: ${response.body}');

      if (response.statusCode == 201) { // 201 para creación exitosa
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo creado exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al crear el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Obtener lista de cultivos con paginación
  Future<CropListResponse> getCrops({int page = 1, int limit = 10}) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.crop}/crops?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Crops status: ${response.statusCode}');
      print('Crops Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CropListResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        return CropListResponse(
          success: false,
          message: errorData['message'] ?? 'Error al obtener cultivos',
          data: CropListData(
            crops: [],
            pagination: PaginationInfo(
              currentPage: page,
              perPage: limit,
              total: 0,
              totalPages: 1,
              hasNext: false,
              hasPrev: false,
            ),
          ),
        );
      }
    } catch (error) {
      return CropListResponse(
        success: false,
        message: 'Error de conexión: $error',
        data: CropListData(
          crops: [],
          pagination: PaginationInfo(
            currentPage: page,
            perPage: limit,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
        ),
      );
    }
  }

  // Obtener cultivo por ID
  Future<CropResponse> getCropById(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.crop}/crop/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Crop Status: ${response.statusCode}');
      print('Get Crop Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo obtenido exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al obtener el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Actualizar cultivo
  Future<CropResponse> updateCrop(int cropId, Crop crop) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.patch(
        Uri.parse('${Environment.crop}/update/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode(crop.toUpdateJson()),
      );

      print('Update Crop Status: ${response.statusCode}');
      print('Update Crop Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CropResponse(
          success: true,
          message: decodedData['message'] ?? 'Cultivo actualizado exitosamente',
          data: Crop.fromJson(decodedData['data']),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropResponse(
          success: false,
          message: errorData['message'] ?? 'Error al actualizar el cultivo',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error updating crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // Eliminar cultivo
  Future<CropResponse> deleteCrop(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${Environment.crop}/delete/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Delete Crop Status: ${response.statusCode}');
      print('Delete Crop Response: ${response.body}');

      // Manejar correctamente el status 204 (No Content)
      if (response.statusCode == 204 || response.statusCode == 200) {
        // Para status 204, la respuesta está vacía - no intentar parsear JSON
        if (response.statusCode == 204) {
          return CropResponse(
            success: true,
            message: 'Cultivo eliminado exitosamente',
            data: null,
          );
        } else {
          // Para status 200, intentar parsear la respuesta si existe
          if (response.body.isNotEmpty) {
            final decodedData = jsonDecode(response.body);
            return CropResponse(
              success: true,
              message: decodedData['message'] ??
                  'Cultivo eliminado exitosamente',
              data: null,
            );
          } else {
            return CropResponse(
              success: true,
              message: 'Cultivo eliminado exitosamente',
              data: null,
            );
          }
        }
      } else {
        // Manejar otros códigos de error
        if (response.body.isNotEmpty) {
          final errorData = json.decode(response.body);
          return CropResponse(
            success: false,
            message: errorData['message'] ?? 'Error al eliminar el cultivo',
            data: null,
          );
        } else {
          return CropResponse(
            success: false,
            message: 'Error al eliminar el cultivo (Status: ${response
                .statusCode})',
            data: null,
          );
        }
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } on FormatException catch (e) {
      print('FormatException handled: $e');
      if (e.toString().contains('Unexpected end of input')) {
        return CropResponse(
          success: true,
          message: 'Cultivo eliminado exitosamente',
          data: null,
        );
      } else {
        throw Exception('Error de formato en la respuesta: ${e.toString()}');
      }
    } catch (error) {
      print('Error deleting crop: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }
}