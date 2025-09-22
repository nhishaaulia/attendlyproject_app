import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attendlyproject_app/endpoint/endpoint.dart';
import 'package:attendlyproject_app/model/edit_foto_profile_model.dart';
import 'package:attendlyproject_app/model/edit_nama_profile_model.dart';
import 'package:attendlyproject_app/model/profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  ProfileService._();

  /// Mendapatkan profile user dari server
  /// Pemanggilan: ProfileService.getProfile(token)
  /// Headers: Authorization Bearer token
  static Future<DataProfile> getProfile(String token) async {
    final url = Uri.parse(Endpoint.profile);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      final profileResponse = ProfileModel.fromJson(jsonBody);

      return profileResponse.data;
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  /// Edit nama user
  /// Pemanggilan: ProfileService.updateName
  static Future<EditDataNama> updateName({
    required String token,
    required String name,
  }) async {
    final url = Uri.parse(Endpoint.profile);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return EditNamaProfileModel.fromJson(jsonBody).data;
    } else {
      throw Exception('Failed to update profile');
    }
  }

  /// Edit foto profil user dari galeri
  /// Pemanggilan: ProfileService.updatePhoto
  static Future<EditFotoProfileData> updatePhoto({
    required String token,
    required File photoFile,
  }) async {
    final url = Uri.parse(Endpoint.profilePhoto);
    final bytes = await photoFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'profile_photo': base64Image}),
    );
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return EditFotoProfileModel.fromJson(jsonBody).data;
    } else {
      throw Exception('Failed to upload profile photo: \\${response.body}');
    }
  }
}
