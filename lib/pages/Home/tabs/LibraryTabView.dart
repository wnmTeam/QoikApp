import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/LibrarySection.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:badges/badges.dart';

class LibraryTab extends StatefulWidget {
  final String userId;

  LibraryTab({this.userId});

  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab>
    with AutomaticKeepAliveClientMixin {
  LibraryController _libraryController = LibraryController();
  AuthController _authController = AuthController();

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
            categories.insert(0, null);
            print(categories);
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (_authController.isLibraryAdmin())
                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/PendingBooksPage',
                                arguments: {},
                              );
                            },
                            child: Text('_pending_books'),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        StreamBuilder(
                            stream: _libraryController.getPendingBooksCount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data.data() != null) {
                                // TODO add sound here
                                return Badge(
                                  showBadge: snapshot.data['count'] != 0,
                                  badgeColor: Theme.of(context).accentColor,
                                  badgeContent: Text(
                                    snapshot.data['count'].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  position: BadgePosition.topStart(
                                      top: 15, start: 100),
                                );
                              }
                              return Container();
                            }),
                      ],
                    );
                  return Container();
                } else
                  return ListTile(
                    title: Text(categories[index].id),
                    leading: Icon(Icons.category),
                    onTap: () {
                      Navigator.pushNamed(context, '/BooksPage', arguments: {
                        'section': LibrarySection().fromMap(categories[index])
                          ..setId(categories[index].id)
                      });
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
