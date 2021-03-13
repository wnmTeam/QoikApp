import 'dart:io';

class Message {
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';
  static const String DOC = 'doc';

  String id;
  String idOwner;
  String text;
  DateTime date;
  List images = [];
  File doc;

  Message({
    this.idOwner,
    this.text,
    this.date,
    this.images,
    this.doc,
  });

  String get getStringDate {
    return date.day.toString() +
        '/' +
        date.month.toString() +
        '/' +
        date.year.toString();
  }

  Map<String, dynamic> toMap() =>
      {
        ID_OWNER: idOwner,
        TEXT: text,
        DATE: date,
        IMAGES: images,
        DOC: doc,
      };

  Message fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
    this.images = map[IMAGES];
    try {
      print(map[DOC]);
      this.doc = File(map[DOC]);
    } catch (e, s) {
      print(s);
    }

    try {
      this.date = map[DATE].toDate();
    } catch (e) {
      this.date = DateTime.now();
    }
    return this;
  }

  Message setId(String id) {
    this.id = id;
    return this;
  }
}
