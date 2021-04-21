import 'package:timeago/timeago.dart' as timeago;

class Comment {
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';
  static const String IMAGE = 'image';
  static const String FILE = 'file';
  static const String LIKE_COUNT = 'likeCount';

  String idOwner;
  String text;
  int likeCount;
  DateTime date;
  var image;
  var file;

  String id;

  bool isLiked = false;

  Comment({
    this.idOwner,
    this.text,
    this.likeCount,
    this.date,
    this.image,
    this.file,
  });

  String get getStringDate {
    DateTime now = DateTime.now();
    DateTime def = now.subtract(now.difference(this.date));

    return timeago.format(def);
  }

  Map<String, dynamic> toMap() =>
      {
        ID_OWNER: idOwner,
        TEXT: text,
        DATE: date,
        LIKE_COUNT: likeCount,
        IMAGE: image,
        FILE: file,
      };

  Comment fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
    this.date = map[DATE].toDate();
    this.likeCount = map[LIKE_COUNT];
    this.image = map[IMAGE];
    this.file = map[FILE];
    return this;
  }

  setId(String id) {
    this.id = id;
  }
}
