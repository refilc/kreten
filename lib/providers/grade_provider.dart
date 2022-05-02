import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
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
  late String _groups;
  late BuildContext _context;
  List<GroupAverage> _groupAvg = [];

  // Public
  List<Grade> get grades => _grades;
  String get groups => _groups;
  List<GroupAverage> get groupAverages => _groupAvg;

  GradeProvider({
    List<Grade> initialGrades = const [],
    required BuildContext context,
  }) {
    _grades = List.castFrom(initialGrades);
    _context = context;

    if (_grades.isEmpty) restore();
  }

  Future<void> restore() async {
    String? userId = Provider.of<UserProvider>(_context, listen: false).id;

    // Load grades from the database
    if (userId != null) {
      final userQuery = Provider.of<DatabaseProvider>(_context, listen: false).userQuery;

      var dbGrades = await userQuery.getGrades(userId: userId);
      _grades = dbGrades;
      notifyListeners();
      var dbGroupAvgs = await userQuery.getGroupAverages(userId: userId);
      _groupAvg = dbGroupAvgs;
      notifyListeners();
    }
  }

  // Fetches Grades from the Kreta API then stores them in the database
  Future<void> fetch() async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot fetch Grades for User null";
    String iss = user.instituteCode;

    List? gradesJson = await Provider.of<KretaClient>(_context, listen: false).getAPI(KretaAPI.grades(iss));
    if (gradesJson == null) throw "Cannot fetch Grades for User ${user.id}";
    List<Grade> grades = gradesJson.map((e) => Grade.fromJson(e)).toList();

    if (grades.isNotEmpty || _grades.isNotEmpty) await store(grades);

    List? groupsJson = await Provider.of<KretaClient>(_context, listen: false).getAPI(KretaAPI.groups(iss));
    if (groupsJson == null || groupsJson.isEmpty) throw "Cannot fetch Groups for User ${user.id}";
    _groups = (groupsJson[0]["OktatasNevelesiFeladat"] ?? {})["Uid"] ?? "";

    List? groupAvgJson = await Provider.of<KretaClient>(_context, listen: false).getAPI(KretaAPI.groupAverages(iss, _groups));
    if (groupAvgJson == null) throw "Cannot fetch Class Averages for User ${user.id}";
    final groupAvgs = groupAvgJson.map((e) => GroupAverage.fromJson(e)).toList();
    await storeGroupAvg(groupAvgs);
  }

  // Stores Grades in the database
  Future<void> store(List<Grade> grades) async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot store Grades for User null";
    String userId = user.id;

    await Provider.of<DatabaseProvider>(_context, listen: false).userStore.storeGrades(grades, userId: userId);
    _grades = grades;
    notifyListeners();
  }

  Future<void> storeGroupAvg(List<GroupAverage> groupAvgs) async {
    _groupAvg = groupAvgs;

    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot store Grades for User null";
    String userId = user.id;
    await Provider.of<DatabaseProvider>(_context, listen: false).userStore.storeGroupAverages(groupAvgs, userId: userId);
    notifyListeners();
  }
}
