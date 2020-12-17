import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/pages/Group/tabs/MembersTabView.dart';
import 'package:stumeapp/pages/Group/tabs/PostsTabView.dart';

class GroupPage extends StatefulWidget {
  Group group;

  GroupPage(this.group);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {},
            title: widget.group.type == Group.TYPE_UNIVERSITY
                ? Text('My University')
                : Text('My College'),
            subtitle: Text('Damascus University'),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.indigo[200]),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.grey[700]),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
            tabs: [
              Tab(
                icon: Icon(
                  Icons.chat,
                  color: Colors.indigo,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.group,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PostsTab(widget.group),
            MembersTab(widget.group),
          ],
        ),
      ),
    );
  }
}
