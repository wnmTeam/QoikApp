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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex;
  List tabViews = [];

  AuthController _authController = AuthController();
  StorageController _storageController = StorageController();
  NotificationApi _notificationApi = NotificationApi();

  @override
  void initState() {
    _notificationApi.requestNotificationPermissions();
    print('done ');
    _currentIndex = 1;
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
        iconTheme: IconThemeData(color: ConstValues.firstColor),
        backgroundColor: Colors.white,
        title: SvgPicture.asset(
          'assets/logo.svg',
          // width: 24,
          height: 36,
          color: ConstValues.firstColor,
        ),
        centerTitle: false,
        titleSpacing: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(
                Icons.chat,
                color: Colors.blueGrey,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/ChatsPage');
              },
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
      body: FutureBuilder(
        future: _authController.getUserInfo(_authController.getUser.uid),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            User user =
                User().fromMap(snapshot.data.data()).setId(snapshot.data.id);
            MyUser.myUser = user;
            _authController.updateUserTag(user);
//            _storageController.setUser(user);
            return tabViews[_currentIndex];
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _selectedTab(index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
