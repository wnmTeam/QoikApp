import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:stumeapp/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class BooksPage extends StatefulWidget {
  final String category;

  BooksPage({this.category});

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 50;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  LibraryController _libraryController = LibraryController();

  List<DocumentSnapshot> books = [];
  List<DocumentSnapshot> searchBooks = [];
  bool isSearch = false;
  TextEditingController _searchController = TextEditingController();
  int bookCount;
  bool openSearchBar = false;

  @override
  void initState() {
    getMyBooks();
    super.initState();
  }

  // FocusNode focusNode  = FocusNode ();
  @override
  Widget build(BuildContext context) {
    bookCount = isSearch ? searchBooks.length : books.length;
    return Scaffold(
      appBar: AppBar(
        title: openSearchBar
            ? TextField(
                // focusNode: focusNode,
                controller: _searchController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: Languages.translate(
                      context,
                      'search',
                    ),
                    hintStyle: TextStyle(color: Colors.white70)),
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    _search(value.trim());
                  } else {
                    setState(() {
                      isSearch = false;
                    });
                  }
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _search(value.trim());
                  } else {
                    setState(() {
                      isSearch = false;
                    });
                  }
                },
                style: TextStyle(color: Colors.white70),
                textInputAction: TextInputAction.search,
              )
            : Text(widget.category),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                openSearchBar = !openSearchBar;
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   FocusScope.of(context).requestFocus(focusNode);
                // });
              });
            },
          )
        ],
      ),
      body: bookCount == 0
          ? Center(
              child: Text(Languages.translate(context, "empty")),
            )
          : GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              children: List.generate(
                  isSearch ? searchBooks.length : books.length, (index) {
                return BookWidget(
                    book: Book().fromMap(isSearch
                        ? searchBooks[index].data()
                        : books[index].data())
                      ..setId(
                          isSearch ? searchBooks[index].id : books[index].id));
              })),
    );
  }

  void _search(String value) {
    searchBooks.clear();
    for (int i = 0; i < books.length; i++) {
      if (Book().fromMap(books[i].data()).name.contains(value)) {
        searchBooks.add(books[i]);
      }
    }
    setState(() {
      lastDocument = null;
      hasMore = true;
      isSearch = true;
    });
  }

  getMyBooks() async {
    if (!hasMore) {
      print('No More books');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _libraryController
        .getBooks(
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('books');
      print(value.docs.length);
      setState(() {
        books.addAll(value.docs);
        isLoading = false;
        try {
          lastDocument = books.last;
        } catch (e) {}
      });
    });
  }
}

class BookWidget extends StatefulWidget {
  final Book book;

  BookWidget({this.book});

  @override
  _BookWidgetState createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> {
  AuthController _authController = AuthController();

  LibraryController _libraryController = LibraryController();

  User user;

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () async {
        String link = await _libraryController.getDownloadLink(
          id: widget.book.id,
        );
        // await launch(link).then((value) => print('url  ' + link));
        Navigator.pushNamed(context,'/PDFScreen', arguments: {'path': link});
      },
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Text(widget.book.name),
        ],
      ),
    );
  }
}
