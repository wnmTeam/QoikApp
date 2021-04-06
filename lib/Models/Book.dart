class Book {
  static const String URL = 'url';
  static const String NAME = 'name';
  static const String IMG = 'img';

  static const String UNIVERSITY = 'university';
  static const String COLLEGE = 'college';
  static const String PUBLISHER = 'publisher';
  static const String SUBJECT_NAME = 'subject_name';


  String url;
  String name;
  String img;

  String university;
  String college;
  String publisher;
  String subject_name;


  String id;

  Book({
    this.img,
    this.name,
    this.url,
    this.university,
    this.college,
    this.publisher,
    this.subject_name,
  });

  Map<String, dynamic> toMap() => {
    NAME: name,
    URL: url,
    IMG: img,
    COLLEGE: college,
    UNIVERSITY: university,
    PUBLISHER: publisher,
    SUBJECT_NAME: subject_name
  };

  Book fromMap(map) {
    this.img = map[IMG];
    this.name = map[NAME];
    this.url = map[URL];
    this.university = map[UNIVERSITY];
    this.college = map[COLLEGE];
    this.publisher = map[PUBLISHER];
    this.subject_name = map[SUBJECT_NAME];
    return this;
  }

  setId(String id) {
    this.id = id;
  }

  setUrl(String url) {
    this.url = url;
  }
}
