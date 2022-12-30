import 'category.dart';

class Subject {
  String id;
  Category category;
  String name;
  String? renamedTo;

  Subject({
    required this.id,
    required this.category,
    required this.name,
    this.renamedTo
  });

  factory Subject.fromJson(Map json, Map<String, String>? renamedSubjects) {
    final id = json["Uid"] ?? "";
    return Subject(
      id: id,
      category: Category.fromJson(json["Kategoria"] ?? {}),
      name: (json["Nev"] ?? "").trim(),
      renamedTo: renamedSubjects?[id],
    );
  }

  @override
  bool operator ==(other) {
    if (other is! Subject) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
