import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../const_values.dart';
import '../../localization.dart';

class BookInfoPage extends StatefulWidget {
  Book book;
  String type;

  BookInfoPage({
    this.book,
    this.type,
  });

  @override
  _BookInfoPageState createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  Size size;

  double _rate;

  LibraryController _libraryController = LibraryController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
      ),
      body: ListView(
        children: [
          Container(
            height: 150,
            width: size.width,
            color: ConstValues.firstColor[300],
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('_university'),
            subtitle: Text(widget.book.university),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('_college'),
            subtitle: Text(widget.book.college),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.book_fill),
            title: Text('_section'),
            subtitle: Text(widget.book.section),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.bookmark_fill),
            title: Text('subject_name'),
            subtitle: Text(widget.book.subject_name),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('publisher_name'),
            subtitle: Text(widget.book.publisher),
            onTap: () {},
          ),
          SizedBox(
            height: 45,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                elevation: 5,
                onPressed: () async {
                  if (widget.type == 'pending') {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('_rate_book'),
                            content: RatingBar.builder(
                              initialRating: 1,
                              minRating: 1,
                              direction: Axis.horizontal,
                              itemCount: 3,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _rate = rating;
                                });
                              },
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                                child: Text(
                                  Languages.translate(
                                    context,
                                    'ok',
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                    await _libraryController.acceptBook(
                      book: widget.book,
                      rate: _rate,
                    );
                    setState(() {
                      widget.type = null;
                    });
                    // TODO show toast done
                  } else {
                    String link = await _libraryController.getDownloadLink(
                      id: widget.book.id,
                    );
                    Navigator.pushNamed(context, '/PDFScreen',
                        arguments: {'path': link});
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: ConstValues.firstColor,
                child: Container(
                  width: 200,
                  height: 57,
                  child: Center(
                    child: Text(
                      widget.type != 'pending' ? '_open' : '_accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              widget.type == 'pending'
                  ? FloatingActionButton(
                      backgroundColor: ConstValues.firstColor,
                      onPressed: () async {
                        String link = await _libraryController.getDownloadLink(
                          id: widget.book.id,
                        );
                        Navigator.pushNamed(context, '/PDFScreen',
                            arguments: {'path': link});
                      },
                      child: Icon(CupertinoIcons.book_fill),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
