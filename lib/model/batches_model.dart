// To parse this JSON data, do
//
//     final BatchesModel = BatchesModelFromJson(jsonString);

import 'dart:convert';

BatchesModel batchesModelFromJson(String str) =>
    BatchesModel.fromJson(json.decode(str));

String batchesModelToJson(BatchesModel data) => json.encode(data.toJson());

class BatchesModel {
  String message;
  List<DataBatches> data;

  BatchesModel({required this.message, required this.data});

  factory BatchesModel.fromJson(Map<String, dynamic> json) => BatchesModel(
    message: json["message"],
    data: List<DataBatches>.from(
      json["data"].map((x) => DataBatches.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DataBatches {
  int id;
  String batchKe;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  DateTime updatedAt;
  List<Training> trainings;

  DataBatches({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.trainings,
  });

  factory DataBatches.fromJson(Map<String, dynamic> json) => DataBatches(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    trainings: List<Training>.from(
      json["trainings"].map((x) => Training.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date":
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "trainings": List<dynamic>.from(trainings.map((x) => x.toJson())),
  };
}

class Training {
  int id;
  String title;
  Pivot pivot;

  Training({required this.id, required this.title, required this.pivot});

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    pivot: Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "pivot": pivot.toJson(),
  };
}

class Pivot {
  String trainingBatchId;
  String trainingId;

  Pivot({required this.trainingBatchId, required this.trainingId});

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    trainingBatchId: json["training_batch_id"],
    trainingId: json["training_id"],
  );

  Map<String, dynamic> toJson() => {
    "training_batch_id": trainingBatchId,
    "training_id": trainingId,
  };
}
