import 'package:filcnaplo_kreta_api/models/subject.dart';

class GroupAverage {
  String uid;
  double average;
  Subject subject;
  Map json;

  GroupAverage({required this.uid, required this.average, required this.subject, this.json = const {}});

  factory GroupAverage.fromJson(Map json, {Map<String, String>? renamedSubjects}) {
    return GroupAverage(
      uid: json["Uid"] ?? "",
      average: json["OsztalyCsoportAtlag"] ?? 0,
      subject: Subject.fromJson(json["Tantargy"] ?? {}, renamedSubjects),
      json: json,
    );
  }
}
