import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class StartChatPage extends StatefulWidget {
  Group group;

  StartChatPage({this.group});

  @override
  _StartChatPageState createState() => _StartChatPageState();
}

class _StartChatPageState extends State<StartChatPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();
  GroupsController _groupsController = GroupsController();

  List<DocumentSnapshot> friends = [null];

  List<String> selectedMembers = [];

  @override
  void initState() {
    getMyFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Start Chat',
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          if (friends[index] == null)
            return Column(
              children: [
                ListTile(
                  title: Text('Create Group'),
                  leading: Icon(Icons.menu),
                  onTap: () {
                    Navigator.pushNamed(context, '/CreateGroupPage');
                  },
                ),
                Divider(),
              ],
            );
          return UserWidget(
            id: friends[index].id,
            addUser: (id, selected) {
              if (selected)
                selectedMembers.add(id);
              else
                selectedMembers.remove(id);
            },
          );
        },
      ),
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
      id: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('friends');
      print(value.docs.length);
      setState(() {
        friends.addAll(value.docs);
        isLoading = false;
        try {
          lastDocument = friends.last;
        } catch (e) {}
      });
    });
  }
}

class UserWidget extends StatefulWidget {
  String id;
  Function addUser;

  UserWidget({this.id, this.addUser});

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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/ChatRoomPage',
                  arguments: {'user': user},
                );
              },
              leading: Container(
                width: 57,
                height: 57,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.indigo[200]),
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
