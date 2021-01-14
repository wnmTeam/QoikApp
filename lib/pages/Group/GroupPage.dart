import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/pages/Group/tabs/MembersTabView.dart';
import 'package:stumeapp/pages/Group/tabs/PostsTabView.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  bool tt = true;

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
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/col.svg',
                    color: Colors.white,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.indigo[300]),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.grey[700]),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
            controller: _tabController,
            tabs: [
              Tab(
//                icon: Icon(
//                  Icons.chat,
//                  color: Colors.indigo,
//                ),
                child: Text(
                  'Posts',
                  style: TextStyle(color: Colors.indigo),
                ),
              ),
              Tab(
//                icon: Icon(
//                  Icons.group,
//                  color: Colors.indigo,
//                ),
                child: Text(
                  'Members',
                  style: TextStyle(color: Colors.indigo),
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

      ),
    );
  }
}
