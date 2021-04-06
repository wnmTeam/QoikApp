class LibrarySection {
  static const String SUBJECTS = 'subjects';

  List subjects;

  String id;

  LibrarySection({
    this.subjects,
  });

  Map<String, dynamic> toMap() => {SUBJECTS: subjects};

  LibrarySection fromMap(map) {
    this.subjects = map[SUBJECTS];
    return this;
  }

  setId(String id) {
    this.id = id;
  }
}
