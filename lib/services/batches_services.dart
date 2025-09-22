import 'dart:convert';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/batches_model.dart';
import 'package:http/http.dart' as http;

class BatchesServices {
  static Map<String, String> _jsonHeaders() => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// ------------------------------------------------------------
  /// Ambil daftar batch dari API
  /// Response akan diparse ke BatchModel (list<DataBatches> ada di dalamnya)
  /// ------------------------------------------------------------
  static Future<BatchesModel> getBatchList() async {
    // Pastikan Endpoints.batches mengarah ke URL endpoint batch
    final url = Uri.parse(Endpoint.batches);

    // Panggil API (GET)
    final response = await http.get(url, headers: _jsonHeaders());

    // Cek status sukses
    if (response.statusCode == 200) {
      // Parse JSON → BatchModel
      return BatchesModel.fromJson(json.decode(response.body));
    } else {
      // Ambil pesan error dari server jika ada
      String message = 'Failed to fetch batches';
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
