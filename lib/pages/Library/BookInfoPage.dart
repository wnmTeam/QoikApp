import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

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

  int _rate;

  LibraryController _libraryController = LibraryController();
  AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.lesson_title),
        actions: [
          _authController.isLibraryAdmin()
              ? PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text('delete'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        _deleteBook();
                        break;
                    }
                  },
                )
              : Container(),
        ],
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
            title: Text(Languages.translate(context, 'university')),
            subtitle: Text(widget.book.university),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(Languages.translate(context, 'college')),
            subtitle: Text(widget.book.college),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.book_fill),
            title: Text(Languages.translate(context, '_section')),
            subtitle: Text(Languages.translate(context, widget.book.section)),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.bookmark_fill),
            title: Text(Languages.translate(context, 'subject_name')),
            subtitle: Text(widget.book.subject_name),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.bookmark_fill),
            title: Text(Languages.translate(context, 'lesson_title')),
            subtitle: Text(widget.book.lesson_title),
            onTap: () {},
          ),
          SizedBox(
            height: 10,
          ),
          FutureBuilder(
              future: _authController.getUserInfo(widget.book.publisher),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  try {
                    User user = User().fromMap(snapshot.data)
                      ..setId(snapshot.data.id);
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/ProfilePage',
                          arguments: {
                            'user': user,
                            'id_user': user.id,
                          },
                        );
                      },
                      leading: Icon(Icons.person),
                      title: Text(
                        user.firstName + ' ' + user.secondName,
                      ),
                      subtitle: Text(
                        user.degree != User.DEGREE_HIGH_SCHOOL
                            ? user.university + ' | ' + user.college
                            : Languages.translate(
                                context,
                                'high school',
                              ),
                      ),
                    );
                  } catch (e) {
                    return Container();
                  }
                }
                return UserPlaceholder();
              }),
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
                            title: Text(
                                Languages.translate(context, '_rate_book')),
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
                                  _rate = rating.toInt();
                                });
                              },
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  _libraryController.acceptBook(
                                    book: widget.book,
                                    rate: _rate,
                                  );
                                  setState(() {
                                    widget.type = null;
                                  });

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
                      widget.type != 'pending'
                          ? Languages.translate(context, '_open')
                          : Languages.translate(context, 'accept'),
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
          SizedBox(height: 25,),
        ],
      ),
    );
  }

  _deleteBook() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Languages.translate(context, '_delete_book')),
            content: Text(Languages.translate(context, 'are_you_sure')),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: Text(
                  Languages.translate(context, 'cancel'),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _libraryController.deleteBook(widget.book);
                  Navigator.pop(
                    context,
                  );
                },
                child: Text(
                  Languages.translate(context, '_yes'),
                ),
              ),
            ],
          );
        });
  }
}
