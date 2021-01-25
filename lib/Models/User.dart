class User {
  static const String FIRST_NAME = 'firstName';
  static const String SECOND_NAME = 'secondName';
  static const String GENDER = 'gender';
  static const String DEGREE = 'degree';
  static const String UNIVERSITY = 'university';
  static const String COLLEGE = 'college';
  static const String GROUPS = 'groups';
  static const String POINTS = 'points';
  static const String TAG = 'tag';
  static const String RECORD_DATE = 'recordDate';
  static const String ENTER_COUNT = 'enterCount';
  static const String BIO = 'bio';
  static const String IMG = 'img';
  static const String EMAIL = 'email';

  static const String TAG_NEW_USER = 'New User';
  static const String TAG_NORMAL_USER = 'Normal User';
  static const String TAG_ACTIVE_USER = 'Active User';
  static const String TAG_EX_USER = 'EX User';
  static const String TAG_SURE_USER = 'sure user';

  String firstName;
  String secondName;
  String gender;
  String degree;
  String university;
  String college;
  List groups;
  int points;
  int enterCount;
  DateTime recordDate;
  String bio;
  String img;
  String email;

  String tag;

  String id;

  User({
    this.firstName,
    this.secondName,
    this.gender,
    this.degree,
    this.university,
    this.college,
    this.points = 0,
    this.groups,
    this.tag = TAG_NEW_USER,
    this.recordDate,
    this.enterCount = 0,
    this.bio,
    this.img = '',
    this.email,
  });

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'secondName': secondName,
        'gender': gender,
        'degree': degree,
        'university': university,
        'college': college,
        GROUPS: groups,
        POINTS: points,
        TAG: tag,
        RECORD_DATE: recordDate,
        ENTER_COUNT: enterCount,
        BIO: bio,
        IMG: img,
        EMAIL: email,
      };

  User fromMap(map) {
    this.firstName = map['firstName'];
    this.secondName = map['secondName'];
    this.gender = map['gender'];
    this.degree = map['degree'];
    this.university = map['university'];
    this.college = map['college'];
    this.groups = map[GROUPS];
    this.points = map[POINTS];
    this.tag = map[TAG];
    this.recordDate = map[RECORD_DATE].toDate();
    this.enterCount = map[ENTER_COUNT];
    this.bio = map[BIO];
    this.img = map[IMG];
    this.email = map[EMAIL];

    return this;
  }

  User setId(String id) {
    this.id = id;
    return this;
  }
}
