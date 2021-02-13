import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';

import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:url_launcher/url_launcher.dart';


class BooksPage extends StatefulWidget {
  String category;

  BooksPage({this.category});

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  LibraryController _libraryController = LibraryController();

  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    getMyBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          children: List.generate(books.length, (index) {
            return BookWidget(book: Book().fromMap(books[index].data()));
          })),
    );
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
      id: widget.category,
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
  Book book;

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
          id: widget.book.name,
        );
        await launch(link)
            .then((value) => print('url  ' + link));
      },
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo[200],
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
