// To parse this JSON data, do
//
//     final CheckInModel = CheckInModelFromJson(jsonString);

import 'dart:convert';

CheckInModel checkInModelFromJson(String str) =>
    CheckInModel.fromJson(json.decode(str));

String checkInModelToJson(CheckInModel data) => json.encode(data.toJson());

class CheckInModel {
  String? message;
  CheckInData data;

  CheckInModel({this.message, required this.data});

  factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
    message: json["message"],
    data: CheckInData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class CheckInData {
  int id;
  DateTime attendanceDate;
  String checkInTime;
  double checkInLat;
  double checkInLng;
  String checkInLocation;
  String checkInAddress;
  String status;
  dynamic alasanIzin;

  CheckInData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInLocation,
    required this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory CheckInData.fromJson(Map<String, dynamic> json) => CheckInData(
    id: json["id"],
    attendanceDate: DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"] ?? '',
    checkInLat: json["check_in_lat"]?.toDouble() ?? 0.0,
    checkInLng: json["check_in_lng"]?.toDouble() ?? 0.0,
    checkInLocation: json["check_in_location"] ?? '',
    checkInAddress: json["check_in_address"] ?? '',
    status: json["status"] ?? '',
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
