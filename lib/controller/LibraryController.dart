import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/api/library_api.dart';

class LibraryController {
  LibraryApi api = LibraryApi();

  Future getCategories() => api.getCategories();

  getBooks({int limit, DocumentSnapshot last}) {
    return api.getBooks(limit: limit, last: last);
  }

  getPendingBooks({int limit, DocumentSnapshot last}) {
    return api.getPendingBooks(limit: limit, last: last);
  }

  getDownloadLink({String category, String id}) {
    return api.getDownloadLink(
      id: id,
    );
  }
}
