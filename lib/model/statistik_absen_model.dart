// To parse this JSON data, do
//
//     final statistikAbsenModel = statistikAbsenModelFromJson(jsonString);

import 'dart:convert';

StatistikAbsenModel statistikAbsenModelFromJson(String str) =>
    StatistikAbsenModel.fromJson(json.decode(str));

String statistikAbsenModelToJson(StatistikAbsenModel data) =>
    json.encode(data.toJson());

class StatistikAbsenModel {
  String message;
  DataStatistik data;

  StatistikAbsenModel({required this.message, required this.data});

  factory StatistikAbsenModel.fromJson(Map<String, dynamic> json) =>
      StatistikAbsenModel(
        message: json["message"],
        data: DataStatistik.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class DataStatistik {
  int totalAbsen;
  int totalMasuk;
  int totalIzin;
  bool sudahAbsenHariIni;

  DataStatistik({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory DataStatistik.fromJson(Map<String, dynamic> json) => DataStatistik(
    totalAbsen: json["total_absen"],
    totalMasuk: json["total_masuk"],
    totalIzin: json["total_izin"],
    sudahAbsenHariIni: json["sudah_absen_hari_ini"],
  );

  Map<String, dynamic> toJson() => {
    "total_absen": totalAbsen,
    "total_masuk": totalMasuk,
    "total_izin": totalIzin,
    "sudah_absen_hari_ini": sudahAbsenHariIni,
  };
}
