import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/LibraryController.dart';

class LibraryTab extends StatefulWidget {
  String id_user;

  LibraryTab({this.id_user});

  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  LibraryController _libraryController = LibraryController();

  List<DocumentSnapshot> books = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: _libraryController.getCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              books = snapshot.data.docs;
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(books[index].id),
                    leading: Icon(Icons.category),
                    onTap: () {},
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
