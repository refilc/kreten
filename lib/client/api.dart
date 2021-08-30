import 'package:intl/intl.dart';

class KretaAPI {
  // IDP API
  static const login = base.KRETA_IDP + kreta.token;
  static const nonce = base.KRETA_IDP + kreta.nonce;
  static const CLIENT_ID = "kreta-ellenorzo-mobile";

  // ELLENORZO API
  static String notes(String iss) => base.kreta(iss) + kreta.notes;
  static String events(String iss) => base.kreta(iss) + kreta.events;
  static String student(String iss) => base.kreta(iss) + kreta.student;
  static String grades(String iss) => base.kreta(iss) + kreta.grades;
  static String absences(String iss) => base.kreta(iss) + kreta.absences;
  static String groups(String iss) => base.kreta(iss) + kreta.groups;
  static String classAverages(String iss, String uid) => base.kreta(iss) + kreta.classAverages + "?oktatasiNevelesiFeladatUid=" + uid;
  static String timetable(String iss, {DateTime? start, DateTime? end}) =>
      base.kreta(iss) +
      kreta.timetable +
      (start != null && end != null ? "?datumTol=" + start.toUtc().toIso8601String() + "&datumIg=" + end.toUtc().toIso8601String() : "");
  static String exams(String iss) => base.kreta(iss) + kreta.exams;
  static String homework(String iss, {DateTime? start, String? id}) =>
      base.kreta(iss) +
      kreta.homework +
      (id != null ? "/$id" : "") +
      (id == null && start != null ? "?datumTol=" + DateFormat('yyyy-MM-dd').format(start) : "");
  static String capabilities(String iss) => base.kreta(iss) + kreta.capabilities;
  static String downloadHomeworkAttachments(String iss, String uid, String type) => base.kreta(iss) + kreta.downloadHomeworkAttachments(uid, type);

  // ADMIN API
  static const sendMessage = base.KRETA_ADMIN + admin.sendMessage;
  static String messages(String endpoint) => base.KRETA_ADMIN + admin.messages(endpoint);
  static String message(String id) => base.KRETA_ADMIN + admin.message(id);
  static const recipientCategories = base.KRETA_ADMIN + admin.recipientCategories;
  static const availableCategories = base.KRETA_ADMIN + admin.availableCategories;
  static const recipientsTeacher = base.KRETA_ADMIN + admin.recipientsTeacher;
  static const uploadAttachment = base.KRETA_ADMIN + admin.uploadAttachment;
  static String downloadAttachment(String id) => base.KRETA_ADMIN + admin.downloadAttachment(id);
  static const trashMessage = base.KRETA_ADMIN + admin.trashMessage;
  static const deleteMessage = base.KRETA_ADMIN + admin.deleteMessage;
}

class base {
  static String kreta(String iss) => "https://$iss.e-kreta.hu";
  static const KRETA_IDP = "https://idp.e-kreta.hu";
  static const KRETA_ADMIN = "https://eugyintezes.e-kreta.hu";
  static const KRETA_FILES = "https://files.e-kreta.hu";
}

class kreta {
  static const token = "/connect/token";
  static const nonce = "/nonce";
  static const notes = "/ellenorzo/V3/Sajat/Feljegyzesek";
  static const events = "/ellenorzo/V3/Sajat/FaliujsagElemek";
  static const student = "/ellenorzo/V3/Sajat/TanuloAdatlap";
  static const grades = "/ellenorzo/V3/Sajat/Ertekelesek";
  static const absences = "/ellenorzo/V3/Sajat/Mulasztasok";
  static const groups = "/ellenorzo/V3/Sajat/OsztalyCsoportok";
  static const classAverages = "/ellenorzo/V3/Sajat/Ertekelesek/Atlagok/OsztalyAtlagok";
  static const timetable = "/ellenorzo/V3/Sajat/OrarendElemek";
  static const exams = "/ellenorzo/V3/Sajat/BejelentettSzamonkeresek";
  static const homework = "/ellenorzo/V3/Sajat/HaziFeladatok";
  // static const homeworkDone = "/ellenorzo/V3/Sajat/HaziFeladatok/Megoldva"; // Removed from the API
  static const capabilities = "/ellenorzo/V3/Sajat/Intezmenyek";
  static String downloadHomeworkAttachments(String uid, String type) => "/ellenorzo/V3/Sajat/HaziFeladatok/Csatolmanyok/$uid,$type";
}

class admin {
  //static const messages = "/api/v1/kommunikacio/postaladaelemek/sajat";
  static const sendMessage = "/api/v1/kommunikacio/uzenetek";
  static String messages(String endpoint) => "/api/v1/kommunikacio/postaladaelemek/$endpoint";
  static String message(String id) => "/api/v1/kommunikacio/postaladaelemek/$id";
  static const recipientCategories = "/api/v1/adatszotarak/cimzetttipusok";
  static const availableCategories = "/api/v1/kommunikacio/cimezhetotipusok";
  static const recipientsTeacher = "/api/v1/kreta/alkalmazottak/tanar";
  static const uploadAttachment = "/ideiglenesfajlok";
  static String downloadAttachment(String id) => "/api/v1/dokumentumok/uzenetek/$id";
  static const trashMessage = "/api/v1/kommunikacio/postaladaelemek/kuka";
  static const deleteMessage = "/api/v1/kommunikacio/postaladaelemek/torles";
}
