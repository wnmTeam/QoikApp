import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LibraryApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  getCategories() {
    return _firestore.collection('books').get();
  }

  getBooks({String id, int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('books')
          .doc(id)
          .collection('books')
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('books')
        .doc(id)
        .collection('books')
        .limit(limit)
        .get();
  }

  getDownloadLink({String id}) {
    return _storage
        .ref()
        .child('books')
        .child('/' + id)
        .getDownloadURL();
  }
}
