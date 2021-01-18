import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/ChatController.dart';

class RoomsTab extends StatefulWidget {
  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab>with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  ChatController _chatsController = ChatController();

  List<DocumentSnapshot> rooms = [null, null];

  @override
  void initState() {
    getRooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (con, index) {
        if (index == 0)
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            leading: Icon(Icons.group),
            title: Text('Create Group'),
            onTap: () {
              Navigator.pushNamed(context, '/CreateGroupPage');
            },
          );
        else if (index == rooms.length - 1) {
          if (isLoading)
            return Center(child: CircularProgressIndicator());
          else if (hasMore)
            return FlatButton(
              onPressed: () {
                getRooms();
              },
              child: Text('Loade More'),
            );
          return Container();
        }
        return _chatBuilder(con, Group().fromMap(rooms[index].data()));
      },
    );
  }

  Widget _chatBuilder(BuildContext context, Group group) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Colors.indigo[200]),
        ),
        title: Text(group.name),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/RoomPage',
            arguments: {
              'user': MyUser.myUser,
              'group': group,
            },
          );
        });
  }

  getRooms() async {
    if (!hasMore) {
      print('No More Rooms');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _chatsController
        .getRooms(
      id_user: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('rooms');
      print(value.docs.length);
      print(value.docs[0].id);
      setState(() {
        rooms.insertAll(rooms.length - 1, value.docs);
        isLoading = false;
        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
