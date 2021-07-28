class Book {
  static const String URL = 'url';
  static const String IMG = 'img';

  static const String SECTION = 'section';
  static const String UNIVERSITY = 'university';
  static const String COLLEGE = 'college';
  static const String PUBLISHER = 'publisher';
  static const String SUBJECT_NAME = 'subject_name';
  static const String LESSON_TITLE = 'lesson_title';
  static const String IS_PENDING = 'is_pending';
  static const String ADMIN = 'admin';

  String url;
  String img;

  String section;
  String university;
  String college;
  String publisher;
  String subject_name;
  String lesson_title;
  bool is_pending;
  String admin;

  String id;

  Book({
    this.img,
    this.url,
    this.section,
    this.university,
    this.college,
    this.publisher,
    this.subject_name,
    this.lesson_title,
    this.is_pending,
    this.admin,
  });

  Map<String, dynamic> toMap() => {
        URL: url,
        IMG: img,
        SECTION: section,
        COLLEGE: college,
        UNIVERSITY: university,
        PUBLISHER: publisher,
        SUBJECT_NAME: subject_name,
        LESSON_TITLE: lesson_title,
        IS_PENDING: is_pending,
        ADMIN: admin,
      };

  Book fromMap(map) {
    this.img = map[IMG];
    this.url = map[URL];
    this.section = map[SECTION];
    this.university = map[UNIVERSITY];
    this.college = map[COLLEGE];
    this.publisher = map[PUBLISHER];
    this.subject_name = map[SUBJECT_NAME];
    this.lesson_title = map[LESSON_TITLE];
    this.is_pending = map[IS_PENDING];
    this.admin = map[ADMIN];
    this.id = getId();
    return this;
  }

  setId() {
    this.id = publisher + section + university + subject_name + lesson_title;
  }

  setUrl(String url) {
    this.url = url;
  }

  getId() {
    return publisher + section + university + subject_name + lesson_title;
  }
}
