import 'package:filcnaplo_kreta_api/models/subject.dart';

class ClassAverage {
  String uid;
  double average;
  Subject subject;

  ClassAverage({required this.uid, required this.average, required this.subject});

  factory ClassAverage.fromJson(Map json) {
    return ClassAverage(
      uid: json["Uid"] ?? "",
      average: json["OsztalyCsoportAtlag"] ?? 0,
      subject: Subject.fromJson(json["Tantargy"] ?? {}),
    );
  }
}
