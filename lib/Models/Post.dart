import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';
  static const String LIKE_COUNT = 'likeCount';
  static const String COMMENT_COUNT = 'commentCount';

  String id;
  String idOwner;
  String text;
  int likeCount;
  int commentCount;
  DateTime date;

  Post({
    this.idOwner,
    this.text,
    this.likeCount,
    this.commentCount,
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
        COMMENT_COUNT: commentCount,
      };

  Post fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
    this.date = map[DATE].toDate();
    this.likeCount = map[LIKE_COUNT];
    this.commentCount = map[COMMENT_COUNT];
    return this;
  }

  Post setId(String id) {
    this.id = id;
    return this;
  }
}
