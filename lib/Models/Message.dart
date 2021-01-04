class Message {
  static const String ID_OWNER = 'id_owner';
  static const String TEXT = 'text';
  static const String DATE = 'date';
  static const String IMAGES = 'images';

  String id;
  String idOwner;
  String text;
  DateTime date;

  Message({
    this.idOwner,
    this.text,
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
      };

  Message fromMap(map) {
    this.idOwner = map[ID_OWNER];
    this.text = map[TEXT];
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
