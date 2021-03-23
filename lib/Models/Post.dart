import 'package:timeago/timeago.dart' as timeago;


class Post {
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';
  static const String Files = 'files';
  static const String LIKE_COUNT = 'likeCount';
  static const String COMMENT_COUNT = 'commentCount';
  static const String FOLLOW_COUNT = 'followCount';
  static const String COMMENT_POINTED = 'commentPointed';

  String id;
  String idOwner;
  String text;
  String commentPointed;
  int likeCount;
  int commentCount;
  int followCount;
  DateTime date;
  List images = [];
  List files = [];

  bool isLiked = false;

  bool isFollowed = false;

  Post({
    this.idOwner,
    this.text,
    this.likeCount,
    this.commentCount,
    this.followCount,
    this.commentPointed,
    this.date,
    this.images,
    this.files,
  });

  String get getStringDate {
    DateTime now = DateTime.now();
    DateTime def = now.subtract(now.difference(this.date));

    return timeago.format(def);

//    return date.day.toString() +
//        '/' +
//        date.month.toString() +
//        '/' +
//        date.year.toString();
  }

  get getIsFollowed => isFollowed;

  set setIsFollowed(bool b) {
    isFollowed = b;
  }

  set setIsLiked(bool isLiked) {
    this.isLiked = isLiked;
  }

  get getIsLiked => isLiked;

  Map<String, dynamic> toMap() =>
      {
        ID_OWNER: idOwner,
        TEXT: text,
        DATE: date,
        LIKE_COUNT: likeCount,
        COMMENT_COUNT: commentCount,
        FOLLOW_COUNT: followCount,
        COMMENT_POINTED: commentPointed,
        IMAGES: images,
        Files: files,
      };

  Post fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
    this.date = map[DATE].toDate();
    this.likeCount = map[LIKE_COUNT];
    this.commentCount = map[COMMENT_COUNT];
    this.followCount = map[FOLLOW_COUNT];
    this.commentPointed = map[COMMENT_POINTED];
    this.images = map[IMAGES];
    this.files = map[Files];
    return this;
  }

  Post setId(String id) {
    this.id = id;
    return this;
  }
}
