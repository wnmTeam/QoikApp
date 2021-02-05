import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/GroupsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

import '../../const_values.dart';

class SelectFriendsPage extends StatefulWidget {
  Group group;

  String type;

  SelectFriendsPage({this.group, this.type = 'create'});

  @override
  _SelectFriendsPageState createState() => _SelectFriendsPageState();
}

class _SelectFriendsPageState extends State<SelectFriendsPage> {
  bool loading = false;

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
          Languages.translate(
            context,
            'select_members',
          ),
        ),
        actions: [
          // Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           SizedBox(
          //               width: 18,
          //               height: 18,
          //               child: CircularProgressIndicator(
          //                 backgroundColor: Colors.white,
          //               )),
          //           SizedBox(
          //             width: 12,
          //           ),
          //           Text(
          //             Languages.translate(
          //               context,
          //               'whaiting',
          //             ),
          //             style: TextStyle(
          //               color: Colors.white,
          //             ),
          //           ),
          //           SizedBox(
          //             width: 8,
          //           ),
          //         ],
          //       )
          FlatButton(
            onPressed: () async {
              if (loading) {
                return;
              }
              setState(() {
                loading = true;
              });
              if (widget.type == 'create') {
                await _groupsController.createGroup(
                  group: widget.group,
                  uids: selectedMembers..add(_authController.getUser.uid),
                );
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              } else {
                await _groupsController.addMemberToRoom(
                  id_group: widget.group.id,
                  uids: selectedMembers,
                );
                Navigator.pop(context);
              }
            },
            child: Icon(
              loading ? Icons.watch_later_outlined : Icons.done,
              color: Colors.white,
            ),

            // Text(
            //   widget.type == 'create'
            //       ? Languages.translate(
            //           context,
            //           'create_group',
            //         )
            //       : Languages.translate(
            //           context,
            //           'add',
            //         ),
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),
            // ),
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
                child: Text(Languages.translate(
                  context,
                  'load_more',
                )),
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
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    //TODO: Change the placeHolder
                    child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                  ),
                  imageUrl: user.img != null ? user.img : ConstValues.userImage,
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
