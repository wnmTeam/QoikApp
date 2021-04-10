import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stumeapp/Models/Book.dart';

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

   createBookRecord({Book book, String section}) {
    return _firestore.collection('books')
        .doc(section)
        .collection('books').doc(book.id).set(book.toMap());
  }

  addSubject({String subject, String section}) {
    return _firestore.collection('books')
        .doc(section).set({'subjects': FieldValue.arrayUnion([subject])}, SetOptions(merge: true));
  }

}
