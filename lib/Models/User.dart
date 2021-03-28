class User {
  static const String FIRST_NAME = 'firstName';
  static const String SECOND_NAME = 'secondName';
  static const String FULL_NAME = 'fullName';
  static const String GENDER = 'gender';
  static const String DEGREE = 'degree';
  static const String UNIVERSITY = 'university';
  static const String OLD_UNIVERSITY = 'old university';
  static const String COLLEGE = 'college';
  static const String GROUPS = 'groups';
  static const String POINTS = 'points';
  static const String TAG = 'tag';
  static const String RECORD_DATE = 'recordDate';
  static const String ENTER_COUNT = 'enterCount';
  static const String BIO = 'bio';
  static const String IMG = 'img';
  static const String EMAIL = 'email';
  static const String USER_TAG = 'user_tag';
  static const String BAN = 'ban';

  static const String TAG_NEW_USER = 'New User';
  static const String TAG_NORMAL_USER = 'Normal User';
  static const String TAG_ACTIVE_USER = 'Active User';
  static const String TAG_PREMIUM_USER = 'Premium User';
  static const String TAG_VERIFIED_USER = 'Verified User';

  static const String USER_TAG_NEW_ADMIN = 'New Admin';
  static const String USER_TAG_ACTIVE_ADMIN = 'Active Admin';
  static const String USER_TAG_PREMIUM_ADMIN = 'Premium Admin';
  static const String USER_TAG_VERIFIED_ADMIN = 'Verified Admin';
  static const String USER_TAG_NORMAL_USER = 'new_user';
  static const String USER_TAG_ADMIN = 'admin';

  static const String DEGREE_HIGH_SCHOOL = 'high school';

  String firstName;
  String secondName;
  String fullName;
  String gender;
  String degree;
  String university;
  String oldUniversity;
  String college;
  List groups;
  int points;
  int enterCount;
  DateTime recordDate;
  String bio;
  String img;
  String email;
  String userTag;
  DateTime ban;

  String tag;

  String id;

  User({
    this.firstName,
    this.secondName,
    this.gender,
    this.degree,
    this.university,
    this.oldUniversity,
    this.college,
    this.points = 0,
    this.groups,
    this.tag = TAG_NEW_USER,
    this.recordDate,
    this.enterCount = 0,
    this.bio,
    this.img = '',
    this.email,
    this.userTag,
    this.ban,
  });

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'secondName': secondName,
        FULL_NAME: firstName.toLowerCase() + ' ' + secondName.toLowerCase(),
        'gender': gender,
        'degree': degree,
        'university': university,
        OLD_UNIVERSITY: oldUniversity,
        'college': college,
        GROUPS: groups,
        POINTS: points,
        TAG: tag,
        RECORD_DATE: recordDate,
        ENTER_COUNT: enterCount,
        BIO: bio,
        IMG: img,
        EMAIL: email,
        USER_TAG: userTag,
        BAN: ban,
      };

  User fromMap(map) {
    this.firstName = map['firstName'];
    this.secondName = map['secondName'];
    this.gender = map['gender'];
    this.degree = map['degree'];
    this.university = map['university'];
    this.oldUniversity = map[OLD_UNIVERSITY];
    this.college = map['college'];
    this.groups = map[GROUPS];
    this.points = map[POINTS];
    this.tag = map[TAG];
    this.recordDate = map[RECORD_DATE].toDate();
    this.enterCount = map[ENTER_COUNT];
    this.bio = map[BIO];
    this.img = map[IMG];
    this.email = map[EMAIL];
    this.fullName = map[FULL_NAME];
    this.userTag = map[USER_TAG];
    if (null != map[BAN]) this.ban = map[BAN].toDate();
    return this;
  }

  User setId(String id) {
    this.id = id;
    return this;
  }

  bool isAdmin() {
    return userTag == USER_TAG_ACTIVE_ADMIN ||
        userTag == USER_TAG_ADMIN ||
        userTag == USER_TAG_NEW_ADMIN ||
        userTag == USER_TAG_PREMIUM_ADMIN ||
        userTag == USER_TAG_VERIFIED_ADMIN;
  }
}
