// To parse this JSON data, do
//
//     final todayAbsenModel = todayAbsenModelFromJson(jsonString);

import 'dart:convert';

TodayAbsenModel todayAbsenModelFromJson(String str) =>
    TodayAbsenModel.fromJson(json.decode(str));

String todayAbsenModelToJson(TodayAbsenModel data) =>
    json.encode(data.toJson());

class TodayAbsenModel {
  String message;
  DataAbsenToday data;

  TodayAbsenModel({required this.message, required this.data});

  factory TodayAbsenModel.fromJson(
    Map<String, dynamic> json,
  ) => TodayAbsenModel(
    // amankan kalau null / bukan String
    message: (json["message"] ?? '').toString(),
    // amankan kalau "data" null/tipe salah → paksa Map kosong (biar factory DataAbsenToday tetap jalan)
    data: DataAbsenToday.fromJson(
      (json["data"] is Map<String, dynamic>)
          ? json["data"] as Map<String, dynamic>
          : <String, dynamic>{},
    ),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class DataAbsenToday {
  DateTime attendanceDate;
  String checkInTime;
  dynamic checkOutTime;
  String checkInAddress;
  dynamic checkOutAddress;
  String status;
  String alasanIzin;

  DataAbsenToday({
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory DataAbsenToday.fromJson(Map<String, dynamic> json) => DataAbsenToday(
    // kalau attendance_date null → pakai hari ini supaya gak crash
    attendanceDate:
        (json["attendance_date"] != null &&
            json["attendance_date"].toString().isNotEmpty)
        ? DateTime.parse(json["attendance_date"].toString())
        : DateTime.now(),
    checkInTime: (json["check_in_time"] ?? '').toString(),
    checkOutTime: json["check_out_time"], // boleh null
    checkInAddress: (json["check_in_address"] ?? '').toString(),
    checkOutAddress: json["check_out_address"], // boleh null
    status: (json["status"] ?? '').toString(),
    alasanIzin: (json["alasan_izin"] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    "attendance_date":
        "${attendanceDate.year.toString().padLeft(4, '0')}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_out_time": checkOutTime,
    "check_in_address": checkInAddress,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
