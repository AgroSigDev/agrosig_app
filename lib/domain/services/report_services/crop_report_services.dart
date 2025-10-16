import 'dart:convert';
import 'dart:io';
import 'package:agrosig/config/keys.dart';
import 'package:agrosig/data/local_secure/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../models/report/report_model.dart';
import '../../response/response_report/response_report.dart';

class CropReportService {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  // Obtener datos del reporte (este está bien)
  Future<CropReportResponse> getReportData(int cropId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.report}/report-data/$cropId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Report Data Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return CropReportResponse(
          success: true,
          message: 'Datos del reporte obtenidos exitosamente',
          data: CropReport.fromJson(decodedData),
        );
      } else {
        final errorData = json.decode(response.body);
        return CropReportResponse(
          success: false,
          message: errorData['error'] ?? 'Error al obtener datos del reporte',
          data: null,
        );
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error getting report data: $error');
      throw Exception('Error en el servidor: ${error.toString()}');
    }
  }

  // DESCARGAR Y ABRIR PDF - CORREGIDO
  Future<void> downloadAndOpenReportPDF(int cropId, String cropName) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.report}/report-pdf/$cropId'),
        headers: {
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('PDF Download Status: ${response.statusCode}');
      print('PDF Content-Length: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        // Guardar el PDF localmente
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Reporte_${cropName}_${DateTime.now().millisecondsSinceEpoch}.pdf'
            .replaceAll(' ', '_')
            .replaceAll('/', '_');
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);
        print('PDF guardado en: ${file.path}');

        // Abrir el archivo PDF
        await OpenFile.open(file.path);

      } else {
        // Manejar error
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            throw Exception(errorData['error'] ?? 'Error al descargar el PDF');
          } catch (e) {
            throw Exception('Error al descargar el PDF (Status: ${response.statusCode})');
          }
        } else {
          throw Exception('Error al descargar el PDF (Status: ${response.statusCode})');
        }
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (error) {
      print('Error downloading PDF: $error');
      throw Exception('Error al descargar el reporte: ${error.toString()}');
    }
  }

  // Método alternativo para solo descargar (sin abrir)
  Future<String> downloadReportPDF(int cropId, String cropName) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (token == null || refreshToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.report}/report-pdf/$cropId'),
        headers: {
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Reporte_${cropName}_${DateTime.now().millisecondsSinceEpoch}.pdf'
            .replaceAll(' ', '_')
            .replaceAll('/', '_');
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Error al descargar el PDF (Status: ${response.statusCode})');
      }
    } catch (error) {
      throw Exception('Error al descargar el reporte: ${error.toString()}');
    }
  }
}