import 'package:filcnaplo/api/providers/user_provider.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo/models/user.dart';
import 'package:filcnaplo_kreta_api/client/api.dart';
import 'package:filcnaplo_kreta_api/client/client.dart';
import 'package:filcnaplo_kreta_api/models/note.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteProvider with ChangeNotifier {
  late List<Note> _notes;
  late BuildContext _context;
  List<Note> get notes => _notes;

  NoteProvider({
    List<Note> initialNotes = const [],
    required BuildContext context,
  }) {
    _notes = List.castFrom(initialNotes);
    _context = context;

    if (_notes.length == 0) restore();
  }

  Future<void> restore() async {
    String? userId = Provider.of<UserProvider>(_context, listen: false).id;

    // Load notes from the database
    if (userId != null) {
      var dbNotes = await Provider.of<DatabaseProvider>(_context, listen: false).userQuery.getNotes(userId: userId);
      _notes = dbNotes;
      notifyListeners();
    }
  }

  // Fetches Notes from the Kreta API then stores them in the database
  Future<void> fetch() async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot fetch Notes for User null";
    String iss = user.instituteCode;
    List? notesJson = await Provider.of<KretaClient>(_context, listen: false).getAPI(KretaAPI.notes(iss));
    if (notesJson == null) throw "Cannot fetch Notes for User ${user.id}";
    List<Note> notes = notesJson.map((e) => Note.fromJson(e)).toList();
    await store(notes);
  }

  // Stores Notes in the database
  Future<void> store(List<Note> notes) async {
    User? user = Provider.of<UserProvider>(_context, listen: false).user;
    if (user == null) throw "Cannot store Notes for User null";
    String userId = user.id;
    await Provider.of<DatabaseProvider>(_context, listen: false).userStore.storeNotes(notes, userId: userId);

    if (notes.length == 0 && _notes.length == 0) return;

    _notes = notes;
    notifyListeners();
  }
}
