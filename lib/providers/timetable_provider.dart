import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo/database/init.dart';
// import 'package:filcnaplo/models/subject_lesson_count.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo_kreta_api/client/api.dart';
import 'package:filcnaplo_kreta_api/client/client.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/models/week.dart';
import 'package:flutter/material.dart';

class TimetableProvider with ChangeNotifier {
  late List<Lesson> _lessons;
  late Week _lastFetched;
  // late SubjectLessonCount _subjectLessonCount;
  List<Lesson> get lessons => _lessons;
  Week get lastFetched => _lastFetched;
  // SubjectLessonCount get subjectLessonCount => _subjectLessonCount;
  late final UserProvider _user;
  late final DatabaseProvider _database;
  late final KretaClient _kreta;

  TimetableProvider({
    List<Lesson> initialLessons = const [],
    required UserProvider user,
    required DatabaseProvider database,
    required KretaClient kreta,
  })  : _user = user,
        _database = database,
        _kreta = kreta {
    _lessons = List.castFrom(initialLessons);

    if (_lessons.isEmpty) restore();
  }

  Future<void> restore() async {
    String? userId = _user.id;

    // Load lessons from the database
    if (userId != null) {
      final userQuery = _database.userQuery;
      var dbLessons = await userQuery.getLessons(userId: userId, renamedSubjects: await _database.userQuery.renamedSubjects(userId: userId));
      _lessons = dbLessons;
      notifyListeners();
      // var dbLessonCount = await userQuery.getSubjectLessonCount(userId: userId);
      // _subjectLessonCount = dbLessonCount;
      // notifyListeners();
    }
  }

  // Fetches Lessons from the Kreta API then stores them in the database
  Future<void> fetch({Week? week, bool db = true}) async {
    if (week == null) return;
    _lastFetched = week;
    User? user = _user.user;
    if (user == null) throw "Cannot fetch Lessons for User null";
    String iss = user.instituteCode;
    List? lessonsJson = await _kreta.getAPI(KretaAPI.timetable(iss, start: week.start, end: week.end));
    if (lessonsJson == null) throw "Cannot fetch Lessons for User ${user.id}";
    Map<String, String> renamedSubjects =
        (await _database.query.getSettings(_database)).renamedSubjectsEnabled ? await _database.userQuery.renamedSubjects(userId: user.id) : {};
    List<Lesson> lessons = lessonsJson.map((e) => Lesson.fromJson(e, renamedSubjects: renamedSubjects)).toList();

    if (lessons.isEmpty && _lessons.isEmpty) return;

    if (db) await store(lessons);
    _lessons = lessons;
    notifyListeners();
  }

  // Stores Lessons in the database
  Future<void> store(List<Lesson> lessons) async {
    User? user = _user.user;
    if (user == null) throw "Cannot store Lessons for User null";
    String userId = user.id;

    await _database.userStore.storeLessons(lessons, userId: userId);
  }

  // Future<void> setLessonCount(SubjectLessonCount lessonCount, {bool store = true}) async {
  //   _subjectLessonCount = lessonCount;

  //   if (store) {
  //     User? user = Provider.of<UserProvider>(_context, listen: false).user;
  //     if (user == null) throw "Cannot store Lesson Count for User null";
  //     String userId = user.id;

  //     await Provider.of<DatabaseProvider>(_context, listen: false).userStore.storeSubjectLessonCount(lessonCount, userId: userId);
  //   }

  //   notifyListeners();
  // }
}
