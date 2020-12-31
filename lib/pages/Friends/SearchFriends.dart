import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/FriendsController.dart';

class SearchFriendsPage extends StatefulWidget {
  @override
  _SearchFriendsPageState createState() => _SearchFriendsPageState();
}

class _SearchFriendsPageState extends State<SearchFriendsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();

  List<DocumentSnapshot> searchResults = [];

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  searchResults = [];
                  getFriendRequests(_getCases(_searchController.text));
                }
              })
        ],
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search...',
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              searchResults = [];
              getFriendRequests(_getCases(value));
            }
          },
          textInputAction: TextInputAction.search,
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return UserWidget(
              user: User().fromMap(searchResults[index].data())
                ..setId(searchResults[index].id));
        },
      ),
    );
  }

  getFriendRequests(List<String> cases) async {
    if (!hasMore) {
      print('No More results');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _authController
        .getUsers(
      cases: cases,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('results');
      print(value.docs.length);
      setState(() {
        searchResults.addAll(value.docs);
        isLoading = false;
        try {
          lastDocument = searchResults.last;
        } catch (e) {}
      });
    });
  }

  List<String> _getCases(String text) {
    List<String> l = [];
    l.add(text[0]);
    for (int i = 1; i < text.length; i++) l.add(l[i - 1] + text[i]);

    print(l);
    return l;
  }
}

class UserWidget extends StatefulWidget {
  User user;

  UserWidget({this.user});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthController _authController = AuthController();
  FriendsController _friendsController = FriendsController();

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        onTap: () {},
        leading: Container(
          width: 57,
          height: 57,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.indigo[200]),
        ),
        title: Text(widget.user.firstName + ' ' + widget.user.secondName),
        subtitle: Text(
          widget.user.university + ' | ' + widget.user.college,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async {
            await _friendsController.sendRequestFriend(
              id_sender: _authController.getUser.uid,
              id_receiver: widget.user.id,
            );
          },
        ));
  }
}
