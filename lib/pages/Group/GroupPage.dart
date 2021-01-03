import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/pages/Group/tabs/MembersTabView.dart';
import 'package:stumeapp/pages/Group/tabs/PostsTabView.dart';

class GroupPage extends StatefulWidget {
  Group group;

  GroupPage(this.group);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;

  AuthController _authController = AuthController();

  @override
  void initState() {
    print(widget.group.toMap());
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                : widget.group.type == Group.TYPE_COLLEGE
                    ? Text('My College')
                    : Text(widget.group.name),
            subtitle: widget.group.type == Group.TYPE_GROUP
                ? null
                : Text(widget.group.name),
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
            controller: _tabController,
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
          controller: _tabController,
          children: [
            PostsTab(widget.group),
            MembersTab(widget.group),
          ],
        ),
        floatingActionButton: _currentIndex == 0 ||
                (_currentIndex == 1 &&
                    widget.group.admins.contains(_authController.getUser.uid))
            ? FloatingActionButton(
                onPressed: () {
                  if (_currentIndex == 0)
                    Navigator.of(context).pushNamed(
                      '/WritePostPage',
                      arguments: {
                        'group': widget.group,
                      },
                    );
                  else
                    Navigator.of(context).pushNamed(
                      '/SelectMembers',
                      arguments: {
                        'group': widget.group,
                        'type': 'add',
                      },
                    );
                },
                backgroundColor: Colors.indigo,
                child: Icon(
                  _currentIndex == 0 ? Icons.edit : Icons.add,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
