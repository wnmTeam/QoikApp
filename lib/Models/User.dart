class User {
  String firstName;
  String secondName;
  String gender;
  String degree;
  String university;
  String college;

  User({
    this.firstName,
    this.secondName,
    this.gender,
    this.degree,
    this.university,
    this.college,
  });

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'secondName': secondName,
        'gender': gender,
        'degree': degree,
        'university': university,
        'college': college,
      };

  void fromMap(map) {
    this.firstName = map['firstName'];
    this.secondName = map['secondName'];
    this.gender = map['gender'];
    this.degree = map['degree'];
    this.university = map['university'];
    this.college = map['college'];
  }
}
