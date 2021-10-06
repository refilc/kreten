import 'package:filcnaplo/utils/format.dart';
import 'category.dart';
import 'subject.dart';

class Grade {
  Map? json;
  String id;
  DateTime date;
  GradeValue value;
  String teacher;
  String description;
  GradeType type;
  String groupId;
  Subject subject;
  Category? gradeType;
  Category mode;
  DateTime writeDate;
  DateTime seenDate;
  String form;

  Grade({
    required this.id,
    required this.date,
    required this.value,
    required this.teacher,
    required this.description,
    required this.type,
    required this.groupId,
    required this.subject,
    this.gradeType,
    required this.mode,
    required this.writeDate,
    required this.seenDate,
    required this.form,
    this.json,
  });

  factory Grade.fromJson(Map json) {
    return Grade(
      id: json["Uid"] ?? "",
      date: json["KeszitesDatuma"] != null ? DateTime.parse(json["KeszitesDatuma"]).toLocal() : DateTime(0),
      value: GradeValue(
        json["SzamErtek"] ?? 0,
        json["SzovegesErtek"] ?? "",
        json["SzovegesErtekelesRovidNev"] ?? "",
        json["SulySzazalekErteke"] ?? 0,
      ),
      teacher: (json["ErtekeloTanarNeve"] ?? "").trim(),
      description: json["Tema"] ?? "",
      type: json["Tipus"] != null ? Category.getGradeType(json["Tipus"]["Nev"]) : GradeType.unknown,
      groupId: (json["OsztalyCsoport"] ?? {})["Uid"] ?? "",
      subject: Subject.fromJson(json["Tantargy"] ?? {}),
      gradeType: json["ErtekFajta"] != null ? Category.fromJson(json["ErtekFajta"]) : null,
      mode: Category.fromJson(json["Mod"] ?? {}),
      writeDate: json["RogzitesDatuma"] != null ? DateTime.parse(json["RogzitesDatuma"]).toLocal() : DateTime(0),
      seenDate: json["LattamozasDatuma"] != null ? DateTime.parse(json["LattamozasDatuma"]).toLocal() : DateTime(0),
      form: (json["Jelleg"] ?? "Na") != "Na" ? json["Jelleg"] : "",
      json: json,
    );
  }

  bool compareTo(dynamic other) {
    if (this.runtimeType != other.runtimeType) return false;

    if (this.id == other.id && this.seenDate == other.seenDate) {
      return true;
    }

    return false;
  }
}

class GradeValue {
  int value;
  String valueName;
  String shortName;
  int weight;

  GradeValue(this.value, this.valueName, this.shortName, this.weight) {
    this.valueName = this.valueName.split("(")[0];
    String _valueName = valueName.toLowerCase().specialChars();

    if (value == 0 && ["peldas", "jo", "valtozo", "rossz", "hanyag"].contains(_valueName)) {
      weight = 0;

      switch (_valueName) {
        case "peldas":
          value = 5;
          break;
        case "jo":
          value = 4;
          break;
        case "valtozo":
          value = 3;
          break;
        case "rossz":
          value = 2;
          break;
        case "hanyag":
          value = 2;
          break;
      }
    }
  }
}

enum GradeType { midYear, firstQ, secondQ, halfYear, thirdQ, fourthQ, endYear, levelExam, ghost, unknown }
