class Book {
  static const String URL = 'url';
  static const String NAME = 'name';
  static const String IMG = 'img';

  static const String SECTION = 'section';
  static const String UNIVERSITY = 'university';
  static const String COLLEGE = 'college';
  static const String PUBLISHER = 'publisher';
  static const String SUBJECT_NAME = 'subject_name';
  static const String IS_PENDING = 'is_pending';
  static const String ADMIN = 'admin';

  String url;
  String name;
  String img;

  String section;
  String university;
  String college;
  String publisher;
  String subject_name;
  bool is_pending;
  String admin;

  String id;

  Book({
    this.img,
    this.name,
    this.url,
    this.section,
    this.university,
    this.college,
    this.publisher,
    this.subject_name,
    this.is_pending,
    this.admin,
  });

  Map<String, dynamic> toMap() => {
        NAME: name,
        URL: url,
        IMG: img,
        SECTION: section,
        COLLEGE: college,
        UNIVERSITY: university,
        PUBLISHER: publisher,
        SUBJECT_NAME: subject_name,
        IS_PENDING: is_pending,
        ADMIN: admin,
      };

  Book fromMap(map) {
    this.img = map[IMG];
    this.name = map[NAME];
    this.url = map[URL];
    this.section = map[SECTION];
    this.university = map[UNIVERSITY];
    this.college = map[COLLEGE];
    this.publisher = map[PUBLISHER];
    this.subject_name = map[SUBJECT_NAME];
    this.is_pending = map[IS_PENDING];
    this.admin = map[ADMIN];
    return this;
  }

  setId(String id) {
    this.id = id;
  }

  setUrl(String url) {
    this.url = url;
  }
}
