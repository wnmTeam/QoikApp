import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stumeapp/Models/Book.dart';

class LibraryApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  getCategories() {
    return _firestore
        .collection('appInfo')
        .doc('library_sections')
        .collection('sections')
        .get();
  }

  getBooks({int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('books')
          .where('is_pending', isEqualTo: false)
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('books')
        .where('is_pending', isEqualTo: false)
        .limit(limit)
        .get();
  }

  getPendingBooks({int limit, DocumentSnapshot last}) {
    if (last != null)
      return _firestore
          .collection('books')
          .where('is_pending', isEqualTo: true)
          .startAfterDocument(last)
          .limit(limit)
          .get();

    return _firestore
        .collection('books')
        .where('is_pending', isEqualTo: true)
        .limit(limit)
        .get();
  }

  getDownloadLink({String id}) {
    return _storage.ref().child('books').child('/' + id).getDownloadURL();
  }

  createBookRecord({Book book, String section}) async {
    await _firestore.collection('books').doc(book.id).set(book.toMap());

    return _firestore.collection('pendingBooks').doc(book.id).set({
      'ex': true,
    });
  }

  addSubject({String subject, String section}) {
    return _firestore
      ..collection('appInfo')
          .doc('library_sections')
          .collection('sections')
          .doc(section)
          .set({
        'subjects': FieldValue.arrayUnion([subject])
      }, SetOptions(merge: true));
  }
}
