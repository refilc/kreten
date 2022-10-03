import 'dart:async';

import 'package:filcnaplo/models/settings.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/models/week.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

enum LiveCardState { empty, duringLesson, duringBreak, morning, afternoon, night }

class LiveCardController extends ChangeNotifier {
  Lesson? currentLesson;
  Lesson? nextLesson;
  Lesson? prevLesson;
  List<Lesson>? nextLessons;
  final AnimationController animation;

  BuildContext context;
  LiveCardState currentState = LiveCardState.empty;
  late Timer _timer;
  late TimetableProvider lessonProvider;

  late Duration _delay;

  LiveCardController({
    required this.context,
    required TickerProvider vsync,
  }) : animation = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: vsync,
        ) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => update());
    lessonProvider = Provider.of<TimetableProvider>(context, listen: false);
    lessonProvider.restore().then((_) => update(animationDuration: 0));
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _delay = settingsProvider.bellDelayEnabled ? Duration(seconds: settingsProvider.bellDelay) : const Duration();
  }

  @override
  void dispose() {
    _timer.cancel();
    animation.dispose();
    super.dispose();
  }

  static DateTime _now() {
    return DateTime.now();
  }

  void update({int animationDuration = 500}) async {
    List<Lesson> today = _today(lessonProvider);

    if (today.isEmpty) {
      await lessonProvider.fetch(week: Week.current());
      today = _today(lessonProvider);
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _delay = settingsProvider.bellDelayEnabled ? Duration(seconds: settingsProvider.bellDelay) : const Duration();

    final now = _now().add(_delay);
    bool notify = false;

    // Filter cancelled lessons #20
    today = today.where((lesson) => lesson.status?.name != "Elmaradt").toList();

    if (today.isNotEmpty) {
      // sort
      today.sort((a, b) => a.start.compareTo(b.start));

      final _lesson = today.firstWhere((l) => l.start.isBefore(now) && l.end.isAfter(now), orElse: () => Lesson.fromJson({}));

      if (_lesson.start.year != 0) {
        currentLesson = _lesson;
        notify = true;
      } else {
        if (currentLesson != null) notify = true;
        currentLesson = null;
      }

      final _next = today.firstWhere((l) => l.start.isAfter(_now()), orElse: () => Lesson.fromJson({}));
      nextLessons = today.where((l) => l.start.isAfter(_now())).toList();

      if (_next.start.year != 0) {
        nextLesson = _next;
      } else {
        nextLesson = null;
      }

      final _prev = today.lastWhere((l) => l.end.isBefore(now), orElse: () => Lesson.fromJson({}));

      if (_prev.start.year != 0) {
        prevLesson = _prev;
      } else {
        prevLesson = null;
      }
    }

    if (currentLesson != null) {
      currentState = LiveCardState.duringLesson;
    } else if (nextLesson != null && prevLesson != null) {
      currentState = LiveCardState.duringBreak;
    } else if (now.hour >= 12 && now.hour < 20) {
      currentState = LiveCardState.afternoon;
    } else if (now.hour >= 20) {
      currentState = LiveCardState.night;
    } else if (now.hour >= 5 && now.hour <= 10) {
      currentState = LiveCardState.morning;
    } else {
      currentState = LiveCardState.empty;
    }

    animation.animateTo(show ? 1.0 : 0.0, curve: Curves.easeInOut, duration: Duration(milliseconds: animationDuration));

    if (notify) notifyListeners();
  }

  bool get show => currentState != LiveCardState.empty;

  Duration get delay => _delay;

  bool _sameDate(DateTime a, DateTime b) => (a.year == b.year && a.month == b.month && a.day == b.day);

  List<Lesson> _today(TimetableProvider p) => p.lessons.where((l) => _sameDate(l.date, _now())).toList();
}
