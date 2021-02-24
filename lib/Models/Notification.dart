import 'package:timeago/timeago.dart' as timeago;


class Notification {
  static const String ID_SENDER = 'id_sender';
  static const String ID_RECEIVER = 'id_receiver';
  static const String ID_POST = 'id_post';
  static const String ID_GROUP = 'id_group';
  static const String DATE = 'date';
  static const String TYPE = 'type';
  static const String DATA = 'data';

  String id;
  String idSender;
  String idReceiver;
  String idGroup;
  String idPost;

  String data;
  String type;
  DateTime date;

  Notification({
    this.idSender,
    this.idReceiver,
    this.idGroup,
    this.idPost,
    this.data,
    this.date,
    this.type,
  });

  String get getStringDate {
    DateTime now = DateTime.now();
    DateTime def = now.subtract(now.difference(this.date));

    return timeago.format(def);
  }

  Map<String, dynamic> toMap() => {
        ID_SENDER: idSender,
        ID_RECEIVER: idReceiver,
        ID_GROUP: idGroup,
        ID_POST: idPost,
        DATA: data,
        DATE: date,
        TYPE: type,
      };

  Notification fromMap(map) {
    this.idSender = map[ID_SENDER];
    this.idReceiver = map[ID_RECEIVER];
    this.idGroup = map[ID_GROUP];
    this.idPost = map[ID_POST];
    this.data = map[DATA];
    this.type = map[TYPE];
    try {
      this.date = map[DATE].toDate();
    } catch (e) {
      this.date = DateTime.now();
    }
    return this;
  }

  Notification setId(String id) {
    this.id = id;
    return this;
  }
}
