class Group {
  String name;
  String img;
  String type;

  static const String TYPE_UNIVERSITY = 'university';
  static const String TYPE_COLLEGE = 'college';
  static const String TYPE_CHAT = 'chat';

  Group({this.name, this.type, this.img = ''});
}
