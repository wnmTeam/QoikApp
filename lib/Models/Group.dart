class Group {
  String name;
  String img;
  String type;

  static final String TYPE_UNIVERSITY = 'university';
  static final String TYPE_COLLEGE = 'college';
  static final String TYPE_CHAT = 'chat';

  Group({this.name, this.type, this.img = ''});
}
