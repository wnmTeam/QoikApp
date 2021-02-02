class Book {
  static const String URL = 'url';
  static const String NAME = 'name';
  static const String IMG = 'img';

  String url;
  String name;
  String img;

  String id;

  Book({
    this.img,
    this.name,
    this.url,
  });

  Map<String, dynamic> toMap() => {
    NAME: name,
    URL: url,
    IMG: img,
  };

  Book fromMap(map) {
    this.img = map[IMG];
    this.name = map[NAME];
    this.url = map[URL];
    return this;
  }

  setId(String id) {
    this.id = id;
  }
}
