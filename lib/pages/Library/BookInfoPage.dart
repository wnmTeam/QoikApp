import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';

import '../../const_values.dart';

class BookInfoPage extends StatefulWidget {
  Book book;

  BookInfoPage({this.book});

  @override
  _BookInfoPageState createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  Size size;

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
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('_open'),
            style: ButtonStyle(),
          ),
        ],
      ),
    );
  }
}
