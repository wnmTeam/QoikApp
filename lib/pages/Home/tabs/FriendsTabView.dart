import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class FriendsTab extends StatefulWidget {
  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> friends = [null, null];

  @override
  void initState() {
    getMyFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(friends);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              if (index == 0)
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        elevation: 0,
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/MyFriendsPage',
                            arguments: {'id_user': _authController.getUser.uid},
                          );
                        },
                        color: Colors.grey[300],
                        child: Text('Friend Requests'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                  ],
                );
              else if (index == friends.length - 1)
                return SizedBox(
                  height: 30,
                );
              return UserWidget(id: friends[index].id);
            },
          ),
        ),
      ],
    );
  }

  getMyFriends() async {
    if (!hasMore) {
      print('No More friends');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _friendsController
        .getFriends(
      id: MyUser.myUser.id,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('friends');
      print(value.docs.length);
      setState(() {
        friends.insertAll(friends.length - 1, value.docs);
        isLoading = false;
        try {
          lastDocument = friends.last;
        } catch (e) {}
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class UserWidget extends StatefulWidget {
  String id;

  UserWidget({this.id});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthController _authController = AuthController();

  User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authController.getUserInfo(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data)..setId(widget.id);
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {},
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: Image.network(
                  user.img,
                  fit: BoxFit.cover,
                  width: 57,
                  height: 57,
                ),
              ),
              title: Text(user.firstName + ' ' + user.secondName),
              subtitle: Text(
                user.university + ' | ' + user.college,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          }
          return Container();
        });
  }
}
