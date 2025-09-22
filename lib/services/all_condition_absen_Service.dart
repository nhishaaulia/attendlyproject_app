import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/check_in_model.dart';
import 'package:attendlyproject_app/model/check_out_model.dart';
import 'package:attendlyproject_app/model/history_absen_model.dart';
// === MODELS ===

import 'package:attendlyproject_app/model/statistik_absen_model.dart';
import 'package:attendlyproject_app/model/today_absen_model.dart';
import 'package:attendlyproject_app/preferences/shared_preferenced.dart';
import 'package:http/http.dart' as http;

/// Service
/// - History (list)
/// - Statistik (summary)
/// - Today (absen hari ini)
/// - Check-in
/// - Check-out

class AttendanceApiService {
  AttendanceApiService._();

  static const Duration _timeout = Duration(seconds: 15);

  // ========== Helpers umum ==========
  static Map<String, String> _authJsonHeaders(String token) {
    if (token.isEmpty) {
      throw Exception('Token not found / expired');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Format jam yang diterima backend (H:i → HH:mm)
  static String _fmtHi(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static Future<Map<String, dynamic>> _postJson({
    required Uri uri,
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    try {
      final res = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return <String, dynamic>{};
        final parsed = jsonDecode(res.body);
        return (parsed is Map<String, dynamic>) ? parsed : {'raw': parsed};
      }

      String msg = 'HTTP ${res.statusCode}';
      try {
        final err = jsonDecode(res.body);
        if (err is Map) {
          if (err['message'] is String) msg = err['message'];
          if (err['errors'] is Map) {
            final det = (err['errors'] as Map).entries
                .map((e) => '${e.key}: ${(e.value as List).join(", ")}')
                .join(' | ');
            msg = '$msg • $det';
          }
        }
      } catch (_) {}
      throw Exception(msg);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }

  static Future<http.Response> _get({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    try {
      final res = await http.get(uri, headers: headers).timeout(_timeout);
      return res;
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    }
  }

  // ========== Endpoints ==========

  /// HISTORY (list semua riwayat)
  /// Return: List<DataHistory>
  /// final items = await AttendanceApi.historyList(token);
  static Future<List<DataHistory>> historyList(String token) async {
    final uri = Uri.parse(Endpoint.allHistoryAbsen);
    final res = await _get(uri: uri, headers: _authJsonHeaders(token));

    if (res.statusCode == 200) {
      final model = HistoryModel.fromJson(jsonDecode(res.body));
      return model.data;
    }
    throw Exception('Failed load history (${res.statusCode})');
  }

  /// STATISTIK (ringkasan)
  /// Return: DataStatistik
  /// final sum = await AttendanceApi.summary(token);
  static Future<DataStatistik> summary(String token) async {
    final uri = Uri.parse(Endpoint.statAbsen);
    final res = await _get(uri: uri, headers: _authJsonHeaders(token));

    if (res.statusCode == 200) {
      final model = StatistikAbsenModel.fromJson(jsonDecode(res.body));
      return model.data;
    }
    throw Exception('Failed load statistic (${res.statusCode})');
  }

  /// TODAY (absen hari ini atau tanggal tertentu)
  /// Return: DataAbsenToday? (null kalau tidak ada data)
  ///   final today = await AttendanceApi.today(token);
  ///   final other = await AttendanceApi.today(token, date: DateTime(2025,9,21));
  static Future<DataAbsenToday?> today(String token, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    final uri = Uri.parse(Endpoint.todayAbsen(_fmtDate(d)));

    final res = await _get(uri: uri, headers: _authJsonHeaders(token));
    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);
      if (parsed is Map && parsed['data'] == null) return null;
      return TodayAbsenModel.fromJson(parsed).data;
    }
    if (res.statusCode == 204 || res.statusCode == 404) {
      return null; // tidak ada absen hari ini
    }
    throw Exception('Failed load today`s attendance (${res.statusCode})');
  }

  /// CHECK-IN
  /// - attendance_date: YYYY-MM-DD
  /// - check_in: HH:mm
  /// - check_in_lat/lng, check_in_location, check_in_address
  ///
  /// Return: CheckInModel
  ///   final res = await AttendanceApi.punchIn(
  ///     token: token, lat: -6.2, lng: 106.8,
  ///     address: 'Jl. Mawar No.1', location: '-6.2,106.8',
  ///   );
  static Future<CheckInModel> punchIn({
    required String token,
    required double lat,
    required double lng,
    required String address,
    required String location,
    DateTime? dateOverride, // opsional jika mau set tanggal manual
    String? timeOverrideHi, // opsional jam "HH:mm"
  }) async {
    final today = dateOverride ?? DateTime.now();
    final jam = timeOverrideHi ?? _fmtHi(DateTime.now());

    final body = <String, dynamic>{
      'attendance_date': _fmtDate(today),
      'check_in': jam,

      'check_in_lat': lat,
      'check_in_lng': lng,
      'check_in_location': location,
      'check_in_address': address,
    };

    final jsonMap = await _postJson(
      uri: Uri.parse(Endpoint.checkIn),
      headers: _authJsonHeaders(token),
      body: body,
    );
    return CheckInModel.fromJson(jsonMap);
  }

  /// CHECK-OUT
  /// - attendance_date: YYYY-MM-DD
  /// - check_out: HH:mm
  /// - check_out_lat/lng, check_out_location, check_out_address
  ///
  /// Return: CheckOutModel
  ///   final res = await AttendanceApi.punchOut(
  ///     token: token, lat: -6.2, lng: 106.8,
  ///     address: 'Jl. Mawar No.1', location: '-6.2,106.8',
  ///   );
  static Future<CheckOutModel> punchOut({
    required String token,
    required double lat,
    required double lng,
    required String address,
    required String location,
    DateTime? dateOverride, // opsional
    String? timeOverrideHi, // opsional jam "HH:mm"
  }) async {
    final today = dateOverride ?? DateTime.now();
    final jam = timeOverrideHi ?? _fmtHi(DateTime.now());

    final body = <String, dynamic>{
      'attendance_date': _fmtDate(today),
      'check_out': jam,

      'check_out_lat': lat,
      'check_out_lng': lng,
      'check_out_location': location,
      'check_out_address': address,
    };

    final jsonMap = await _postJson(
      uri: Uri.parse(Endpoint.checkOut),
      headers: _authJsonHeaders(token),
      body: body,
    );
    return CheckOutModel.fromJson(jsonMap);
  }

  static Future<TodayAbsenModel?> getAbsenToday() async {
    try {
      final token = await PreferenceHandler.getToken();
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse("${Endpoint.absenToday}?attendance_date=$attendanceDate"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return TodayAbsenModel.fromJson(jsonDecode(response.body));
      } else {
        print("Get Absen Today Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Get Absen Today: $e");
      return null;
    }
  }
}
