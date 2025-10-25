import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class CustomHttpClient {
  static http.Client create() {
    final HttpClient httpClient = HttpClient();

    // Ignorar errores de certificados
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('Ignorando certificado autofirmado para: $host:$port');
      return true;
    };

    return IOClient(httpClient);
  }
}