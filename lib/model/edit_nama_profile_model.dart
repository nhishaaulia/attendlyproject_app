// To parse this JSON data, do
//
//     final EditNamaProfileModel = EditNamaProfileModelFromJson(jsonString);

import 'dart:convert';

EditNamaProfileModel editNamaProfileModelFromJson(String str) =>
    EditNamaProfileModel.fromJson(json.decode(str));

String editNamaProfileModelToJson(EditNamaProfileModel data) =>
    json.encode(data.toJson());

class EditNamaProfileModel {
  String message;
  EditDataNama data;

  EditNamaProfileModel({required this.message, required this.data});

  factory EditNamaProfileModel.fromJson(Map<String, dynamic> json) =>
      EditNamaProfileModel(
        message: json["message"],
        data: EditDataNama.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class EditDataNama {
  int id;
  String name;
  String email;
  dynamic emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;

  EditDataNama({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EditDataNama.fromJson(Map<String, dynamic> json) => EditDataNama(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
