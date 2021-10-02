import 'category.dart';
import 'package:filcnaplo/utils/format.dart';

class Subject {
  String id;
  Category category;
  String name;

  Subject({
    required this.id,
    required this.category,
    required this.name,
  });

  factory Subject.fromJson(Map json) {
    return Subject(
      id: json["Uid"] ?? "",
      category: Category.fromJson(json["Kategoria"] ?? {}),
      name: (json["Nev"] ?? "").trim(),
    );
  }

  factory Subject.fromString(String name) {
    return Subject(
      id: "",
      category: Category(
        id: "",
        description: name,
        name: name.specialChars(),
      ),
      name: name,
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
