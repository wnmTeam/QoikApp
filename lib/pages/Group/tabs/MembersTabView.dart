import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/GroupsController.dart';

class MembersTab extends StatefulWidget {
  Group group;

  MembersTab(this.group);

  @override
  _MembersTabState createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> with AutomaticKeepAliveClientMixin{
  ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;

  GroupsController _groupsController = GroupsController();

  List<DocumentSnapshot> members = [];

  @override
  void initState() {
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getMembers();
      }
    });
    getMembers();
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
    return Column(children: [
      Expanded(
        child: members.length == 0
            ? Center(
          child: Text('No Data...'),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: members.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: (){

              },
              title: Text(members[index].data()['name']),
              subtitle: Text(members[index].data()['activeState']),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.indigo[200]),
              ),
            );
          },
        )
      ),
      isLoading
          ? Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5),
        color: Colors.yellowAccent,
        child: Text(
          'Loading',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : Container()
    ]);
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
