// To parse this JSON data, do
//
//     final TrainingsModel = TrainingsModelFromJson(jsonString);

import 'dart:convert';

TrainingsModel trainingsModelFromJson(String str) =>
    TrainingsModel.fromJson(json.decode(str));

String trainingsModelToJson(TrainingsModel data) => json.encode(data.toJson());

class TrainingsModel {
  String message;
  List<DataTrainings> data;

  TrainingsModel({required this.message, required this.data});

  factory TrainingsModel.fromJson(Map<String, dynamic> json) => TrainingsModel(
    message: json["message"],
    data: List<DataTrainings>.from(
      json["data"].map((x) => DataTrainings.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DataTrainings {
  int id;
  String title;

  DataTrainings({required this.id, required this.title});

  factory DataTrainings.fromJson(Map<String, dynamic> json) =>
      DataTrainings(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
