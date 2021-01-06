import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryApi{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getCategories() {
    return _firestore.collection('books').get();
  }
}