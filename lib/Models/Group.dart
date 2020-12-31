class Group {
  String name;
  String img;
  String type;
  List members;

  String id;

  static const String TYPE_UNIVERSITY = 'university';
  static const String TYPE_COLLEGE = 'college';
  static const String TYPE_CHAT = 'chat';
  static const String TYPE_GROUP = 'group';
  static const String NAME = 'name';
  static const String MEMBERS = 'members';
  static const String IMG = 'img';
  static const String TYPE = 'type';

  Group({this.name, this.type, this.img = ''});

  Group fromMap(map) {
    this.name = map[NAME];
    this.members = map[MEMBERS];
    this.type = map[TYPE];
    return this;
  }

  Map<String, dynamic> toMap() => {
    NAME: name,
    TYPE: type,
    MEMBERS: members,
  };

  Group setId(String id) {
    this.id = id;
    return this;
  }

}
