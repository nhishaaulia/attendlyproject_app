// To parse this JSON data, do
//
//     final requstOtpModel = requstOtpModelFromJson(jsonString);

import 'dart:convert';

RequstOtpModel requstOtpModelFromJson(String str) =>
    RequstOtpModel.fromJson(json.decode(str));

String requstOtpModelToJson(RequstOtpModel data) => json.encode(data.toJson());

class RequstOtpModel {
  String? message;

  RequstOtpModel({this.message});

  factory RequstOtpModel.fromJson(Map<String, dynamic> json) =>
      RequstOtpModel(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
