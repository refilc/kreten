import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo_kreta_api/client/api.dart';
import 'package:filcnaplo_kreta_api/client/client.dart';
import 'package:filcnaplo_kreta_api/models/grade.dart';
import 'package:filcnaplo_kreta_api/models/group_average.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GradeProvider with ChangeNotifier {
  // Private
  late List<Grade> _grades;
  late DateTime _lastSeen;
  late String _groups;
  List<GroupAverage> _groupAvg = [];
  late final SettingsProvider _settings;
  late final UserProvider _user;
  late final DatabaseProvider _database;
  late final KretaClient _kreta;

  // Public
  List<Grade> get grades => _grades;
  DateTime get lastSeenDate => _settings.gradeOpeningFun ? _lastSeen : DateTime(3000);
  String get groups => _groups;
  List<GroupAverage> get groupAverages => _groupAvg;

  GradeProvider({
    List<Grade> initialGrades = const [],
    required SettingsProvider settings,
    required UserProvider user,
    required DatabaseProvider database,
    required KretaClient kreta,
  }) {
    _settings = settings;
    _user = user;
    _database = database;
    _kreta = kreta;

    _grades = List.castFrom(initialGrades);
    _lastSeen = DateTime.now();

    if (_grades.isEmpty) restore();
  }

  Future<void> seenAll() async {
    String? userId = _user.id;
    if (userId != null) {
      final userStore = _database.userStore;
      userStore.storeLastSeenGrade(DateTime.now(), userId: userId);
      _lastSeen = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> restore() async {
    String? userId = _user.id;

    // Load grades from the database
    if (userId != null) {
      final userQuery = _database.userQuery;

      _grades = await userQuery.getGrades(userId: userId);
      notifyListeners();
      _groupAvg = await userQuery.getGroupAverages(userId: userId);
      notifyListeners();
      DateTime lastSeenDB = await userQuery.lastSeenGrade(userId: userId);
      if (lastSeenDB.millisecondsSinceEpoch == 0 || lastSeenDB.year == 0 || !_settings.gradeOpeningFun) {
        _lastSeen = DateTime.now();
        await seenAll();
      } else {
        _lastSeen = lastSeenDB;
      }
      notifyListeners();
    }
  }

  // Fetches Grades from the Kreta API then stores them in the database
  Future<void> fetch() async {
    User? user = _user.user;
    if (user == null) throw "Cannot fetch Grades for User null";
    String iss = user.instituteCode;

    List? gradesJson = await _kreta.getAPI(KretaAPI.grades(iss));
    if (gradesJson == null) throw "Cannot fetch Grades for User ${user.id}";
    List<Grade> grades = gradesJson.map((e) => Grade.fromJson(e)).toList();

    if (grades.isNotEmpty || _grades.isNotEmpty) await store(grades);

    List? groupsJson = await _kreta.getAPI(KretaAPI.groups(iss));
    if (groupsJson == null || groupsJson.isEmpty) throw "Cannot fetch Groups for User ${user.id}";
    _groups = (groupsJson[0]["OktatasNevelesiFeladat"] ?? {})["Uid"] ?? "";

    List? groupAvgJson = await _kreta.getAPI(KretaAPI.groupAverages(iss, _groups));
    if (groupAvgJson == null) throw "Cannot fetch Class Averages for User ${user.id}";
    final groupAvgs = groupAvgJson.map((e) => GroupAverage.fromJson(e)).toList();
    await storeGroupAvg(groupAvgs);
  }

  // Stores Grades in the database
  Future<void> store(List<Grade> grades) async {
    User? user = _user.user;
    if (user == null) throw "Cannot store Grades for User null";
    String userId = user.id;

    await _database.userStore.storeGrades(grades, userId: userId);
    _grades = grades;
    notifyListeners();
  }

  Future<void> storeGroupAvg(List<GroupAverage> groupAvgs) async {
    _groupAvg = groupAvgs;

    User? user = _user.user;
    if (user == null) throw "Cannot store Grades for User null";
    String userId = user.id;
    await _database.userStore.storeGroupAverages(groupAvgs, userId: userId);
    notifyListeners();
  }
}
