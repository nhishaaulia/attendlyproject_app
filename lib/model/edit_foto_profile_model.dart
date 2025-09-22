// To parse this JSON data, do
//
//     final EditFotoProfileModel = EditFotoProfileModelFromJson(jsonString);

import 'dart:convert';

EditFotoProfileModel editFotoProfileModelFromJson(String str) =>
    EditFotoProfileModel.fromJson(json.decode(str));

String editFotoProfileModelToJson(EditFotoProfileModel data) =>
    json.encode(data.toJson());

class EditFotoProfileModel {
  String message;
  EditFotoProfileData data;

  EditFotoProfileModel({required this.message, required this.data});

  factory EditFotoProfileModel.fromJson(Map<String, dynamic> json) =>
      EditFotoProfileModel(
        message: json["message"],
        data: EditFotoProfileData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class EditFotoProfileData {
  String profilePhoto;

  EditFotoProfileData({required this.profilePhoto});

  factory EditFotoProfileData.fromJson(Map<String, dynamic> json) =>
      EditFotoProfileData(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
