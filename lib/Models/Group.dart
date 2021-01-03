class Group {
  String name;
  String img;
  String type;
  List members = [];
  List admins = [];
  DateTime lastActive;

  String id;

  static const String TYPE_UNIVERSITY = 'university';
  static const String TYPE_COLLEGE = 'college';
  static const String TYPE_CHAT = 'chat';
  static const String TYPE_GROUP = 'group';
  static const String NAME = 'name';
  static const String MEMBERS = 'members';
  static const String IMG = 'img';
  static const String TYPE = 'type';
  static const String LAST_ACTIVE = 'lastActive';
  static const String ADMINS = 'admins';

  Group({
    this.name = '',
    this.type,
    this.img = '',
    this.members,
    this.admins,
  });

  Group fromMap(map) {
    this.name = map[NAME];
    this.members = map[MEMBERS];
    this.admins = map[ADMINS];
    this.type = map[TYPE];
    return this;
  }

  Map<String, dynamic> toMap() => {
        NAME: name,
        TYPE: type,
        MEMBERS: members,
        ADMINS: admins,
      };

  Group setId(String id) {
    this.id = id;
    return this;
  }

  addMembers(List selectedMembers) {
    members.addAll(selectedMembers);
    return this;
  }
}
