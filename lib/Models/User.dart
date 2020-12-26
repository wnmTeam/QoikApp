class User {

  static final String FIRST_NAME  = 'firstName';
  static final String SECOND_NAME  = 'secondName';
  static final String GENDER  = 'gender';
  static final String DEGREE  = 'degree';
  static final String UNIVERSITY  = 'university';
  static final String COLLEGE  = 'college';

  String firstName;
  String secondName;
  String gender;
  String degree;
  String university;
  String college;

  String id;

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

  User fromMap(map) {
    this.firstName = map['firstName'];
    this.secondName = map['secondName'];
    this.gender = map['gender'];
    this.degree = map['degree'];
    this.university = map['university'];
    this.college = map['college'];

    return this;
  }

  void setId(String id){
    this.id = id;
  }

}
