import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class PendingBooksPage extends StatefulWidget {
  @override
  _PendingBooksPageState createState() => _PendingBooksPageState();
}

class _PendingBooksPageState extends State<PendingBooksPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  bool noBooks = false;

  LibraryController _libraryController = LibraryController();

  Size size;

  List<DocumentSnapshot> books = [
    null,
    null,
  ];

  @override
  void initState() {
    getPendingBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(
          context,
          '_pending_books',
        )),
      ),
      body: !noBooks
          ? ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                if (index == 0)
                  return SizedBox(
                    height: 10,
                  );
                else if (index == books.length - 1) {
                  if (isLoading)
                    return Center(child: CircularProgressIndicator());
                  else if (hasMore)
                    return FlatButton(
                      onPressed: () {
                        getPendingBooks();
                      },
                      child: Text(Languages.translate(
                        context,
                        'load_more',
                      )),
                    );
                  return Container();
                }
                return BookWidget(book: Book().fromMap(books[index].data()));
              },
            )
          : Padding(
              padding: const EdgeInsets.all(80.0),
              child: Center(
                child: Image.asset('assets/empty2.png'),
              ),
            ),
    );
  }

  getPendingBooks() async {
    if (!hasMore) {
      print('No More pending books');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _libraryController
        .getPendingBooks(
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('books');
      print(value.docs.length);
      setState(() {
        if (value.docs.length == 0)
          noBooks = true;
        else
          noBooks = false;
        books.insertAll(books.length - 1, value.docs);
        isLoading = false;
        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class BookWidget extends StatefulWidget {
  final Book book;

  BookWidget({this.book});

  @override
  _BookWidgetState createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> {
  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      onTap: () {
        Navigator.of(context).pushNamed('/BookInfoPage', arguments: {
          'book': widget.book,
          'type': 'pending',
        });
      },
      leading: Icon(
        CupertinoIcons.doc_fill,
        color: ConstValues.firstColor,
        size: 50,
      ),
      title: Text(widget.book.lesson_title),
      subtitle: Text(Languages.translate(
            context,
            widget.book.section,
          ) +
          ' | ' +
          widget.book.subject_name),
    );
  }
}
