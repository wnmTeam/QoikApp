import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/pages/Home/tabs/FriendsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/GroupsChatsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/HomeTabView.dart';
import 'package:stumeapp/pages/Home/tabs/LibraryTabView.dart';
import 'package:stumeapp/pages/Home/widgets/FABwithBottomAppBar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex;
  List tabViews = [];

  AuthController _authController = AuthController();
  StorageController _storageController = StorageController();

  @override
  void initState() {
    _currentIndex = 0;
    tabViews = [
      HomeTab(),
      GroupsChatsTab(),
      FriendsTab(),
      LibraryTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.indigo),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('LOGO'),
        ),
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.indigo[200]),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Omar alkadi',
                    style: TextStyle(
                        color: Colors.grey[700], fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: FABBottomAppBar(
        notchedShape: CircularNotchedRectangle(),
        selectedColor: Colors.indigo,
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(
            iconData: Icons.home,
            text: 'Home',
          ),
          FABBottomAppBarItem(
            iconData: Icons.chat_rounded,
            text: 'Groups',
          ),
          FABBottomAppBarItem(
            iconData: Icons.group,
            text: 'Griends',
          ),
          FABBottomAppBarItem(
            iconData: Icons.library_books,
            text: 'Library',
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Container(),),
            ListTile(
              title: Text('Log out'),
              leading: Icon(Icons.logout),
              onTap: (){
                _authController.logOut();
              },
            )
          ],
        ),
      ),
      drawerScrimColor: Colors.indigo,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: tabViews[_currentIndex],
    );
  }

  void _selectedTab(index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
