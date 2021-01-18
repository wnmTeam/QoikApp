import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/ChatController.dart';

class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  ChatController _chatsController = ChatController();

  List<DocumentSnapshot> chats = [null, null];

  @override
  void initState() {
    getChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (con, index) {
        if (index == 0)
          return SizedBox(
            height: 20,
          );
        else if (index == chats.length - 1) {
          if (isLoading)
            return Center(child: CircularProgressIndicator());
          else if (hasMore)
            return FlatButton(
              onPressed: () {
                getChats();
              },
              child: Text('Loade More'),
            );
          return Container();
        }
        return _chatBuilder(con, Group().fromMap(chats[index].data()));
      },
    );
  }

  Widget _chatBuilder(BuildContext context, Group group) {
    User user;
    return FutureBuilder(
      future: _authController.getUserInfo(
        _authController.getUser.uid == group.members[0]
            ? group.members[1]
            : group.members[0],
      ),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data.data()).setId(snapshot.data.id);
          return ListTile(
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
            subtitle: Text('New User'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/ChatRoomPage',
                arguments: {
                  'user': user,
                  'group': group,
                },
              );
            },
          );
        }
        return Container();
      },
    );
  }

  getChats() async {
    if (!hasMore) {
      print('No More chats');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _chatsController
        .getChats(
      id_user: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('chats');
      print(value.docs.length);
      setState(() {
        chats.insertAll(chats.length - 1, value.docs);
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
