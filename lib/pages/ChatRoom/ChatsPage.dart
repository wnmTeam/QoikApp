import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/ChatRoom/tabs/ChatsTap.dart';
import 'package:stumeapp/pages/ChatRoom/tabs/RoomsTap.dart';
import 'package:stumeapp/pages/Group/tabs/MembersTabView.dart';
import 'package:stumeapp/pages/Group/tabs/PostsTabView.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;

  AuthController _authController = AuthController();

  @override
  void initState() {
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
          backgroundColor: ConstValues.firstColor,
          title: TabBar(
            indicatorColor: Colors.white70,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(Languages.translate(
                  context,
                  'chats',
                ),),
              ),
              Tab(
                child: Text(Languages.translate(
                  context,
                  'rooms',
                ),),
              ),
            ],
          ),

        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ChatsTab(),
            RoomsTab(),
          ],
        ),
      ),
    );
  }
}
