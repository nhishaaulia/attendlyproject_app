import 'dart:convert';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/training_model.dart';
import 'package:http/http.dart' as http;

class TrainingsService {
  // Header untuk request JSON
  static Map<String, String> _jsonHeaders() => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// ------------------------------------------------------------
  /// Ambil daftar training dari API
  /// Response akan diparse ke TrainingsModel (list<DataTrainings> ada di dalamnya)
  /// ------------------------------------------------------------
  static Future<TrainingsModel> getTrainingList() async {
    final url = Uri.parse(Endpoint.trainings);

    // Panggil API (GET)
    final response = await http.get(url, headers: _jsonHeaders());

    // Cek status sukses
    if (response.statusCode == 200) {
      // Parse JSON → TrainingsModel
      return TrainingsModel.fromJson(json.decode(response.body));
    } else {
      // Ambil pesan error dari server jika ada
      String message = 'Failed to fetch trainings';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
}
