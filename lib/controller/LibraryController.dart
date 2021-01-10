import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/api/library_api.dart';

class LibraryController {
  LibraryApi api = LibraryApi();

  Future getCategories() => api.getCategories();

  getBooks({String id, int limit, DocumentSnapshot last}) {
    return api.getBooks(id: id, limit: limit, last: last);
  }

  getDownloadLink({String category, String id}) {
    return api.getDownloadLink(
      id: id,
    );
  }
}
