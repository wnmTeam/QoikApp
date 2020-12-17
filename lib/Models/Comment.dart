class Comment{
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';
  static const String LIKE_COUNT = 'likeCount';

  String idOwner;
  String text;
  int likeCount;
  DateTime date;

  Comment({
    this.idOwner,
    this.text,
    this.likeCount,
    this.date,
  });

  String get getStringDate {
    return date.day.toString() +
        '/' +
        date.month.toString() +
        '/' +
        date.year.toString();
  }

  Map<String, dynamic> toMap() => {
    ID_OWNER: idOwner,
    TEXT: text,
    DATE: date,
    LIKE_COUNT: likeCount,
  };

  Comment fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
    this.date = map[DATE].toDate();
    this.likeCount = map[LIKE_COUNT];
    return this;
  }
}