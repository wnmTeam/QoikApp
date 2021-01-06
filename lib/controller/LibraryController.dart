import 'package:stumeapp/api/library_api.dart';

class LibraryController{
  LibraryApi api = LibraryApi();

  Future getCategories() => api.getCategories();
}