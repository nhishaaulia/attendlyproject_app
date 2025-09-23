import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/login_model.dart';
import 'package:attendlyproject_app/model/register_model.dart';
import 'package:attendlyproject_app/pages/preference/shared.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // ---------- Headers ----------
  static Map<String, String> _jsonHeaders() => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _jsonAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  static String _parseErrorMessage(
    http.Response response, {
    String fallback = 'Request failed',
  }) {
    try {
      final body = json.decode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return '$fallback (Status: ${response.statusCode})';
  }

  // ---------- REGISTER ----------
  static Future<RegisterUserModel> registerUser(
    String name,
    String email,
    String password,
    String jenisKelamin,
    String profilePhoto, // kirim DataURL/base64 atau sesuai backend
    int batchId,
    int trainingId,
  ) async {
    final url = Uri.parse(Endpoint.register);

    final response = await http
        .post(
          url,
          headers: _jsonHeaders(),
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'jenis_kelamin': jenisKelamin,
            'profile_photo': profilePhoto,
            'batch_id': batchId,
            'training_id': trainingId,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final reg = RegisterUserModel.fromJson(json.decode(response.body));
      // simpan token kalau backend mengembalikan
      if (reg.data.token.isNotEmpty) {
        await PreferenceHandler.saveToken(reg.data.token);
      }
      return reg;
    } else {
      throw Exception(
        _parseErrorMessage(response, fallback: 'Failed to register user'),
      );
    }
  }

  // ---------- LOGIN tanpa token ----------
  static Future<LoginUserModel> loginNoToken(
    String email,
    String password,
  ) async {
    final url = Uri.parse(Endpoint.login);
    final body = {'email': email, 'password': password};

    try {
      final response = await http
          .post(url, headers: _jsonHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final login = LoginUserModel.fromJson(json.decode(response.body));
        await PreferenceHandler.saveToken(login.data.token);
        return login;
      } else {
        throw Exception(
          _parseErrorMessage(response, fallback: 'Failed to login user'),
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out while logging in');
    } on SocketException {
      throw Exception('No internet connection');
    }
  }

  // ---------- LOGIN dengan token (fallback) ----------
  static Future<LoginUserModel> loginWithToken(
    String email,
    String password,
    String token,
  ) async {
    final url = Uri.parse(Endpoint.login);
    final headers = token.isNotEmpty ? _jsonAuthHeaders(token) : _jsonHeaders();
    final body = {'email': email, 'password': password};

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final login = LoginUserModel.fromJson(json.decode(response.body));
        await PreferenceHandler.saveToken(login.data.token);
        return login;
      } else {
        throw Exception(
          _parseErrorMessage(response, fallback: 'Failed to login user'),
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out while logging in (token)');
    } on SocketException {
      throw Exception('No internet connection');
    }
  }

  static Future<LoginUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);
    final response = await http.post(
      url,
      body: {"email": email, "password": password},
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      final data = LoginUserModel.fromJson(json.decode(response.body));
      await PreferenceHandler.saveToken(data.data.token);
      await PreferenceHandler.saveLogin();
      // await PreferenceHandler.saveUserId(data.data.user.id);
      print("UserId saved: ${data.data.user.id}");
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }
}
