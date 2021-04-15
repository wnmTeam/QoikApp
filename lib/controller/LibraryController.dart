import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/api/library_api.dart';

class LibraryController {
  LibraryApi api = LibraryApi();

  Future getCategories() => api.getCategories();

  getBooks({int limit, DocumentSnapshot last, String section}) {
    return api.getBooks(limit: limit, last: last, section: section);
  }

  getPendingBooks({int limit, DocumentSnapshot last}) {
    return api.getPendingBooks(limit: limit, last: last);
  }

  getDownloadLink({String category, String id}) {
    return api.getDownloadLink(
      id: id,
    );
  }

  acceptBook({Book book, int rate}) {
    return api.acceptBook(book: book, rate: rate);
  }

  getPendingBooksCount() {
    return api.getPendingBooksCount();
  }
}
