import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
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

  List<DocumentSnapshot> friendRequests = [null];

  @override
  void initState() {
    getFriendRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: friendRequests.length,
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
                    Navigator.of(context).pushNamed('/MyFriendsPage',
                        arguments: {'id_user': _authController.getUser.uid});
                  },
                  color: Colors.grey[300],
                  child: Text('My Friends'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              )
            ],
          );
        return RequestFriendWidget(friendRequests[index].id);
      },
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

  @override
  bool get wantKeepAlive => true;
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
  GroupsController _groupsController = GroupsController();

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
                await _groupsController.createChat(
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
