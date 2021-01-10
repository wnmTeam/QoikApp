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

  List<DocumentSnapshot> categories = [];

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
              categories = snapshot.data.docs;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(categories[index].id),
                    leading: Icon(Icons.category),
                    onTap: () {
                      Navigator.pushNamed(context, '/BooksPage', arguments: {'category': categories[index].id});
                    },
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
