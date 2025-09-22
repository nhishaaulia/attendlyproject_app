import 'dart:convert';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/forgot_password_model.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static Future<RequstOtpModel> requestOtp(String email) async {
    final url = Uri.parse(Endpoint.requestOtp);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RequstOtpModel.fromJson(data);
    } else {
      throw Exception(
        'Gagal mengirim permintaan OTP. Status: ${response.statusCode}',
      );
    }
  }

  static Future<RequstOtpModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'otp': otp, 'password': newPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RequstOtpModel.fromJson(data);
    } else {
      throw Exception('Gagal reset password. Status: ${response.statusCode}');
    }
  }
}
