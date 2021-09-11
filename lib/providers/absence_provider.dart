import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo_kreta_api/client/api.dart';
import 'package:filcnaplo_kreta_api/client/client.dart';
import 'package:filcnaplo_kreta_api/models/absence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AbsenceProvider with ChangeNotifier {
  late List<Absence> _absences;
  late BuildContext _context;
  List<Absence> get absences => _absences;

  AbsenceProvider({
    List<Absence> initialAbsences = const [],
    required BuildContext context,
  }) {
    _absences = List.castFrom(initialAbsences);
    _context = context;

    if (_absences.length == 0) restore();
  }

  Future<void> restore() async {
    String? userId = Provider.of<UserProvider>(_context, listen: false).id;

    // Load absences from the database
    if (userId != null) {
      var dbAbsences = await Provider.of<DatabaseProvider>(_context, listen: false).userQuery.getAbsences(userId: userId);
      _absences = dbAbsences;
      notifyListeners();
    }
  }

  // Fetches Absences from the Kreta API then stores them in the database
  Future<void> fetch() async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot fetch Absences for User null";
    String iss = user.instituteCode;

    List? absencesJson = await Provider.of<KretaClient>(_context, listen: false).getAPI(KretaAPI.absences(iss));
    if (absencesJson == null) throw "Cannot fetch Absences for User ${user.id}";
    List<Absence> absences = absencesJson.map((e) => Absence.fromJson(e)).toList();

    if (absences.length != 0 || _absences.length != 0) await store(absences);
  }

  // Stores Absences in the database
  Future<void> store(List<Absence> absences) async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot store Absences for User null";
    String userId = user.id;

    await Provider.of<DatabaseProvider>(_context, listen: false).userStore.storeAbsences(absences, userId: userId);
    _absences = absences;
    notifyListeners();
  }
}
