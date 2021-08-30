class School {
  String instituteCode;
  String name;
  String city;

  School({
    required this.instituteCode,
    required this.name,
    required this.city,
  });

  factory School.fromJson(Map json) {
    return School(
      instituteCode: json["instituteCode"] ?? "",
      name: json["name"] ?? "",
      city: json["city"] ?? "",
    );
  }
}
