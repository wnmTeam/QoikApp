import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class MembersTab extends StatefulWidget {
  Group group;

  MembersTab(this.group);

  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;

  GroupsController _groupsController = GroupsController();

  AuthController _authController = AuthController();

  List<DocumentSnapshot> members = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: widget.group.members.length,
      itemBuilder: (_, index) {
        return FutureBuilder(
            future: _authController.getUserInfo(widget.group.members[index]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                User user = User()
                    .fromMap(snapshot.data.data())
                    .setId(snapshot.data.id);
                print(user.id);
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/ProfilePage',
                      arguments: {
                        'id_user': user.id,
                        'user': user,
                      },
                    );
                  },
                  title: Text(user.firstName + ' ' + user.secondName),
                  subtitle: Text('New User'),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: Colors.indigo[200]),
                  ),
                );
              }
              return Container();
            });
      },
    );
  }

  getMembers() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    log('hhhhhhhhhhhhhhhhhh', name: 'get members');
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    querySnapshot = await _groupsController.getMembers(
      limit: documentLimit,
      last: lastDocument,
      group: widget.group,
    );
    print('querySnapshot.docs.length' + querySnapshot.docs.length.toString());
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
//    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    members.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
