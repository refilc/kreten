class Homework {
  Map? json;
  DateTime date;
  DateTime lessonDate;
  DateTime deadline;
  bool byTeacher;
  bool homeworkEnabled;
  String teacher;
  String content;
  String subjectName;
  String group;
  List<HomeworkAttachment> attachments;
  String id;

  Homework({
    required this.date,
    required this.lessonDate,
    required this.deadline,
    required this.byTeacher,
    required this.homeworkEnabled,
    required this.teacher,
    required this.content,
    required this.subjectName,
    required this.group,
    required this.attachments,
    required this.id,
    this.json,
  });

  factory Homework.fromJson(Map json) {
    return Homework(
      id: json["Uid"] ?? "",
      date: json["RogzitesIdopontja"] != null ? DateTime.parse(json["RogzitesIdopontja"]).toLocal() : DateTime(0),
      lessonDate: json["FeladasDatuma"] != null ? DateTime.parse(json["FeladasDatuma"]).toLocal() : DateTime(0),
      deadline: json["HataridoDatuma"] != null ? DateTime.parse(json["HataridoDatuma"]).toLocal() : DateTime(0),
      byTeacher: json["IsTanarRogzitette"] ?? true,
      homeworkEnabled: json["IsTanuloHaziFeladatEnabled"] ?? false,
      teacher: json["RogzitoTanarNeve"] ?? "",
      content: (json["Szoveg"] ?? "").trim(),
      subjectName: json["TantargyNeve"] ?? "",
      group: json["OsztalyCsoport"] != null ? json["OsztalyCsoport"]["Uid"] ?? "" : "",
      attachments: ((json["Csatolmanyok"] ?? []) as List).cast<Map>().map((Map json) => HomeworkAttachment.fromJson(json)).toList(),
      json: json,
    );
  }
}

class HomeworkAttachment {
  Map? json;
  String id;
  String name;
  String type;

  HomeworkAttachment({required this.id, this.name = "", this.type = "", this.json});

  factory HomeworkAttachment.fromJson(Map json) {
    return HomeworkAttachment(
      id: json["Uid"],
      name: json["Nev"],
      type: json["Tipus"],
      json: json,
    );
  }
}
