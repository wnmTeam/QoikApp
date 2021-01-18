import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class SelectFriendsPage extends StatefulWidget {
  Group group;

  String type;

  SelectFriendsPage({this.group, this.type = 'create'});

  @override
  _SelectFriendsPageState createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();
  GroupsController _groupsController = GroupsController();

  List<DocumentSnapshot> friends = [null, null];

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
          'Select Members',
          style: TextStyle(color: Colors.grey[700]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        actions: [
          FlatButton(
            onPressed: () async {
              if (widget.type == 'create') {
                await _groupsController.createGroup(
                  group: widget.group,
                  uids: selectedMembers..add(_authController.getUser.uid),
                );
                Navigator.popUntil(context, ModalRoute.withName('/ChatsPage'));
              } else {
                print(widget.group.id);
                print(selectedMembers);
                await _groupsController.addMemberToGroup(
                  id_group: widget.group.id,
                  uids: selectedMembers,
                );
                Navigator.pop(context);
              }
            },
            child: widget.type == 'create' ? Text('Create Group') : Text('add'),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          if (index == 0)
            return SizedBox(
              height: 20,
            );
          else if (index == friends.length - 1) {
            if (isLoading)
              return Center(child: CircularProgressIndicator());
            else if (hasMore)
              return FlatButton(
                onPressed: () {
                  getMyFriends();
                },
                child: Text('Loade More'),
              );
            return Container();
          }
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
        friends.insertAll(friends.length - 1, value.docs);
        isLoading = false;
        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
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
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authController.getUserInfo(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data)..setId(widget.id);
            return ListTile(
              selectedTileColor: Colors.blueGrey[100],
              selected: selected,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {
                setState(() {
                  selected = !selected;
                  widget.addUser(widget.id, selected);
                });
              },
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
          return UserPlaceholder();
        });
  }
}
