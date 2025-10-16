import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../config/keys.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../../models/plot/plot_model.dart';
import '../../response/response_default/response_default.dart';
import '../../response/response_plot/response_plot.dart';
import '../../response/response_plot/response_ubication.dart';

class PlotServices {
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  // ========== REGISTER PLOT ==========
  Future<PlotResponse> registerPlot({
    required String plotName,
    required String location,
    required double lat,
    required double long,
    required double area,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('No authentication token found');
      }

      print('Registering plot with data:');
      print('Plot Name: $plotName');
      print('Location: $location');
      print('Lat: $lat, Long: $long');
      print('Area: $area');

      final response = await http.post(
        Uri.parse('${Environment.plots}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': '$refreshToken',
        },
        body: jsonEncode({
          'plot_name': plotName,
          'location': location,
          'lat': lat,
          'long': long,
          'area': area,
        }),
      );

      print('Plot Register Status: ${response.statusCode}');
      print('Plot Register Response: ${response.body}');

      if (response.statusCode == 201) {
        return PlotResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error creating plot');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Register plot error: $e');
      throw Exception('Error creating plot: ${e.toString()}');
    }
  }

  // ========== GET PLOT BY USER ID ==========
  // ========== GET PLOT BY USER ID ==========
  Future<Plot?> getPlotByUserId() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken(); // Corregido: getRefreshToken
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('Authentication required');
      }

      // PRIMERO: Obtener las coordenadas para conseguir el plot_id
      final coordsResponse = await http.get(
        Uri.parse('${Environment.plots}/ubication-plot/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': refreshToken,
        },
      );

      print('Get Coordinates Status: ${coordsResponse.statusCode}');
      print('Get Coordinates Response: ${coordsResponse.body}');

      if (coordsResponse.statusCode == 200) {
        final coordsData = jsonDecode(coordsResponse.body);
        if (coordsData['data'] != null && coordsData['data'].isNotEmpty) {
          final plotId = coordsData['data'][0]['plot_id'];

          // SEGUNDO: Ahora obtener los datos completos de la parcela
          final response = await http.get(
            Uri.parse('${Environment.plots}/get-plot/$plotId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'x-refresh-token': refreshToken,
            },
          );

          print('Get Plot Status: ${response.statusCode}');
          print('Get Plot Response: ${response.body}');

          if (response.statusCode == 200) {
            final decodedData = jsonDecode(response.body);
            if (decodedData['data'] != null) {
              return Plot.fromJson(decodedData['data']);
            }
          }
        }
        return null;
      } else {
        final errorData = jsonDecode(coordsResponse.body);
        throw Exception(errorData['message'] ?? 'Error fetching plot coordinates');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get plot error: $e');
      throw Exception('Error fetching plot: ${e.toString()}');
    }
  }

  // ========== GET PLOT LOCATION COORDINATES ==========
  Future<UbicationResponse> getPlotCoordinates() async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${Environment.plots}/ubication-plot/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': '$refreshToken',
        },
      );

      print('Get Coordinates Status: ${response.statusCode}');
      print('Get Coordinates Response: ${response.body}');

      if (response.statusCode == 200) {
        return UbicationResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error fetching coordinates');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Get coordinates error: $e');
      throw Exception('Error fetching coordinates: ${e.toString()}');
    }
  }

  // ========== UPDATE PLOT ==========
  Future<PlotResponse> updatePlot({
    required int plotId,
    required String plotName,
    required String location,
    required double lat,
    required double long,
    required double area,
  }) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || refreshToken == null || userId == null) {
        throw Exception('Authentication required');
      }

      print('Updating plot $plotId with data:');
      print('Plot Name: $plotName');
      print('Location: $location');
      print('Lat: $lat, Long: $long');
      print('Area: $area');

      final response = await http.patch(
        Uri.parse('${Environment.plots}/update/$plotId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-refresh-token': '$refreshToken',
        },
        body: jsonEncode({
          'plot_name': plotName,
          'location': location,
          'lat': lat,
          'long': long,
          'area': area,
        }),
      );

      print('Update Plot Status: ${response.statusCode}');
      print('Update Plot Response: ${response.body}');

      if (response.statusCode == 200) {
        return PlotResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error updating plot');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Update plot error: $e');
      throw Exception('Error updating plot: ${e.toString()}');
    }
  }

  // ========== DELETE PLOT ==========
  Future<ResponseDefault> deletePlot(int plotId) async {
    try {
      final token = await _secureStorage.getAccessToken();
      final userId = await _secureStorage.getUserId();

      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.delete(
        Uri.parse('${Environment.plots}/plots/delete/$plotId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Plot Status: ${response.statusCode}');
      print('Delete Plot Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ResponseDefault(
          resp: true,
          msg: 'Plot deleted successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error deleting plot');
      }
    } on SocketException {
      throw Exception('Error de conexión: No hay internet');
    } catch (e) {
      print('Delete plot error: $e');
      throw Exception('Error deleting plot: ${e.toString()}');
    }
  }
}

final plotServices = PlotServices();