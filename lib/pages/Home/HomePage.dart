import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/pages/Home/tabs/FriendsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/GroupsChatsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/HomeTabView.dart';
import 'package:stumeapp/pages/Home/tabs/LibraryTabView.dart';
import 'package:stumeapp/pages/Home/widgets/FABwithBottomAppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _currentIndex;
  bool loading = true;
  List tabViews = [];

  AuthController _authController = AuthController();
  StorageController _storageController = StorageController();
  NotificationApi _notificationApi = NotificationApi();

  @override
  void initState() {
    _notificationApi.requestNotificationPermissions();
    print('done ');
    _currentIndex = 1;
    _getUserInfo();
    tabViews = [
      HomeTab(),
      GroupsChatsTab(),
      FriendsTab(),
      LibraryTab(),
    ];
  }

  _getUserInfo() async {
    DocumentSnapshot d =
        await _authController.getUserInfo(_authController.getUser.uid);
    User user = User().fromMap(d.data()).setId(d.id);
    MyUser.myUser = user;
    _authController.updateUserTag(user);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ConstValues.firstColor,
        title: SvgPicture.asset(
          'assets/logo.svg',
          // width: 24,
          height: 36,
          color: Colors.white,
        ),
        centerTitle: false,
        titleSpacing: 5,
//        leading: Row(
//          children: [
//            IconButton(
//              icon: Icon(Icons.menu),
//              onPressed: () => _scaffoldKey.currentState.openDrawer(),
//            ),
//            IconButton(
//              icon: Icon(
//                Icons.notifications,
//                color: Colors.blueGrey,
//              ),
//              onPressed: () {
//                Navigator.pushNamed(context, '/ChatsPage');
//              },
//            ),
//          ],
//        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/ChatsPage');
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: !loading
                ? InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/ProfilePage',
                        arguments: {
                          'user': MyUser.myUser,
                          'id_user': _authController.getUser.uid,
                        },
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            MyUser.myUser.img != null ? MyUser.myUser.img : ' ',
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          )),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: FABBottomAppBar(
        backgroundColor: ConstValues.firstColor,
        notchedShape: CircularNotchedRectangle(),
        selectedColor: Colors.white,
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
            text: 'Friends',
          ),
          FABBottomAppBarItem(
            iconData: Icons.library_books,
            text: 'Library',
            svgIcon: 'assets/lib.svg',
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          backgroundColor: ConstValues.firstColor,
          onPressed: () {
            if (_currentIndex == 2)
              Navigator.of(context).pushNamed('/SearchFriendsPage');
            else if (_currentIndex == 1)
              Navigator.of(context).pushNamed(
                '/ProfilePage',
                arguments: {
                  'user': MyUser.myUser,
                  'id_user': _authController.getUser.uid
                },
              );
            else
              Navigator.of(context).pushNamed(
                '/ProfilePage',
                arguments: {
                  'user': MyUser.myUser,
                  'id_user': _authController.getUser.uid,
                },
              );
          },
          child: Icon(
            _currentIndex == 2 ? Icons.add : Icons.person,
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Container(),
            ),
            ListTile(
              title: Text('Log out'),
              leading: Icon(Icons.logout),
              onTap: () {
                _authController.logOut();
              },
            )
          ],
        ),
      ),
      drawerScrimColor: ConstValues.firstColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: !loading
          ? tabViews[_currentIndex]
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _selectedTab(index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
