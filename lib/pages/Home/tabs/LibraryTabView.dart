import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/controller/LibraryController.dart';

class LibraryTab extends StatefulWidget {
  final String userId;

  LibraryTab({this.userId});

  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> with AutomaticKeepAliveClientMixin{
  LibraryController _libraryController = LibraryController();

  List<DocumentSnapshot> categories = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
                    Navigator.pushNamed(context, '/BooksPage',
                        arguments: {'category': categories[index].id});
                  },
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  @override
  bool get wantKeepAlive => true;
}
