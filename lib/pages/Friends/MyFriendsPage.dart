import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsRequestsPage extends StatefulWidget {

  String id_user;

  FriendsRequestsPage({this.id_user});

  @override
  _FriendsRequestsPageState createState() => _FriendsRequestsPageState();
}

class _FriendsRequestsPageState extends State<FriendsRequestsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> friendRequests = [];

  @override
  void initState() {
    getFriendRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Friends Requests',
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          return RequestFriendWidget(friendRequests[index].id);
        },
      ),
    );
  }

  getFriendRequests() async {
    if (!hasMore) {
      print('No More requests');
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
        .getFriendRequests(
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('reqs');
      print(value.docs.length);
      setState(() {
        friendRequests.addAll(value.docs);
        isLoading = false;
        lastDocument = friendRequests.last;
      });
    });
  }
}

class RequestFriendWidget extends StatefulWidget {
  String id_sender;

  RequestFriendWidget(this.id_sender);

  @override
  _RequestFriendWidgetState createState() => _RequestFriendWidgetState();
}

class _RequestFriendWidgetState extends State<RequestFriendWidget> {
  AuthController _authController = AuthController();

  User user;

  FriendsController _friendsController = FriendsController();
  ChatController _chatsController = ChatController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authController.getUserInfo(widget.id_sender),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data)..setId(widget.id_sender);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            onTap: () {},
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child:  Image.network(
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
            trailing: RaisedButton(
              elevation: 0,
              color: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'accept',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                await _friendsController.acceptRequestFriend(
                    id_requestSender: user.id);
                print('send done');
                await _chatsController.createChat(
                  group: Group(
                    members: [
                      user.id,
                      _authController.getUser.uid,
                    ],
                    type: Group.TYPE_CHAT,
                    name: '',
                  ).setId(getChatID()),
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  String getChatID() {
    List l = [user.id, _authController.getUser.uid];
    l.sort();

    return l[0] + l[1];
  }
}
