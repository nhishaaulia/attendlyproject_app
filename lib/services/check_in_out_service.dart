import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/check_in_model.dart';
import 'package:attendlyproject_app/model/check_out_model.dart';
import 'package:http/http.dart' as http;

class AuthRequiredException implements Exception {
  final String message;
  AuthRequiredException([this.message = 'Token not found / expired']);
  @override
  String toString() => message;
}

class CheckInOutService {
  CheckInOutService._();

  static const _timeout = Duration(seconds: 15);

  // endpoint path
  static const String _checkInPath = '/absen/check-in';
  static const String _checkOutPath = '/absen/check-out';

  // Header (WAJIB token)
  static Map<String, String> _headers(String token) {
    if (token.isEmpty) throw AuthRequiredException();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===== Helpers =====
  static String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ⬇️ GANTI: format H:i (HH:mm), TANPA detik
  static String _nowHi() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  static Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    final uri = Uri.parse('${Endpoint.baseUrl}$path');

    try {
      final res = await http
          .post(uri, headers: _headers(token), body: jsonEncode(body))
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return <String, dynamic>{};
        final parsed = jsonDecode(res.body);
        return (parsed is Map<String, dynamic>) ? parsed : {'raw': parsed};
      } else {
        String msg = 'An error occured (${res.statusCode})';
        try {
          final err = jsonDecode(res.body);
          if (err is Map) {
            if (err['message'] is String) msg = err['message'];
            if (err['errors'] is Map) {
              final map = err['errors'] as Map;
              final details = map.entries
                  .map((e) => '${e.key}: ${(e.value as List).join(", ")}')
                  .join(' | ');
              msg = '$msg • $details';
            }
          }
        } catch (_) {}
        throw Exception(msg);
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }

  /// CHECK-IN
  static Future<CheckInModel> checkIn({
    required String token,
    required double lat,
    required double lng,
    required String location,
    required String address,
    String? attendanceDate, // opsional override
    String? checkInOverride, // opsional override jam
  }) async {
    final body = {
      'attendance_date': attendanceDate ?? _today(),
      'check_in': checkInOverride ?? _nowHi(), // HH:mm

      'check_in_lat': lat,
      'check_in_lng': lng,
      'check_in_location': location,
      'check_in_address': address,
    };
    final json = await _post(path: _checkInPath, body: body, token: token);
    return CheckInModel.fromJson(json);
  }

  /// CHECK-OUT
  static Future<CheckOutModel> checkOut({
    required String token,
    required double lat,
    required double lng,
    required String location,
    required String address,
    String? attendanceDate, // opsional override
    String? checkOutOverride, // opsional override jam
  }) async {
    final body = {
      'attendance_date': attendanceDate ?? _today(),
      'check_out': checkOutOverride ?? _nowHi(), //HH:mm

      'check_out_lat': lat,
      'check_out_lng': lng,
      'check_out_location': location,
      'check_out_address': address,
    };
    final json = await _post(path: _checkOutPath, body: body, token: token);
    return CheckOutModel.fromJson(json);
  }
}
