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

  LibraryController _libraryController = LibraryController();

  Size size;

  List<DocumentSnapshot> books = [
    null,null,
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
        title: Text('_pending_books'),
      ),
      body: ListView.builder(
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

      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 57,
          height: 57,
          color: ConstValues.firstColor,
        ),
      ),
      title: Text(widget.book.name),
      subtitle: Text(widget.book.section + ' | ' + widget.book.subject_name),
    );
  }
}
