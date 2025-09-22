import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/forgot_password_model.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  ForgotPasswordService._();

  static const _defaultTimeout = Duration(seconds: 15);

  static Map<String, String> _headers() => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // helper post json
  static Future<ForgotPasswordModel> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${Endpoint.baseUrl}$path');

    http.Response res;
    try {
      res = await http
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(_defaultTimeout);
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('The request timed out');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) {
        return ForgotPasswordModel(success: true, message: 'Success', data: {});
      }
      final parsed = jsonDecode(res.body);
      if (parsed is Map<String, dynamic>) {
        return ForgotPasswordModel.fromJson(parsed);
      }
      return ForgotPasswordModel(
        success: true,
        message: 'Success',
        data: {'raw': parsed},
      );
    } else {
      // kalau error ambil message dari body kalau ada
      String msg = 'Terjadi kesalahan (${res.statusCode})';
      try {
        final err = jsonDecode(res.body);
        if (err is Map && err['message'] is String) {
          msg = err['message'];
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// 1) Request OTP
  static Future<ForgotPasswordModel> requestOtp(RequestOtp payload) {
    return _postJson(path: '/forgot-password', body: payload.toJson());
  }

  /// 2) Verifikasi OTP
  static Future<ForgotPasswordModel> verifyOtp(OtpVerify payload) {
    return _postJson(path: '/verify-otp', body: payload.toJson());
  }

  /// 3) Reset Password
  static Future<ForgotPasswordModel> resetPassword(ResetPassword payload) {
    if (payload.password != payload.passwordConfirmation) {
      throw Exception('Your confirmation password doesn`t match.');
    }
    return _postJson(path: '/reset-password', body: payload.toJson());
  }
}
