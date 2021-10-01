import 'package:filcnaplo_kreta_api/controllers/timetable_controller.dart';

class Week {
  DateTime start;
  DateTime end;

  Week({required this.start, required this.end});

  factory Week.current() {
    DateTime _now = DateTime.now();
    // fix #32
    DateTime now = DateTime(_now.year, _now.month, _now.day);
    return Week(
      start: now.subtract(Duration(days: now.weekday - 1)),
      end: now.add(Duration(days: DateTime.daysPerWeek - now.weekday)),
    );
  }

  factory Week.fromId(int id) {
    DateTime now = TimetableController.getSchoolYearStart().add(Duration(days: id * DateTime.daysPerWeek));
    return Week(
      start: now.subtract(Duration(days: now.weekday - 1)),
      end: now.add(Duration(days: DateTime.daysPerWeek - now.weekday)),
    );
  }

  @override
  String toString() => "Week(start: $start, end: $end)";
}
