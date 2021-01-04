import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
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
        iconTheme: IconThemeData(color: Colors.indigo),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('LOGO'),
        ),
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          MyUser.myUser != null
              ? FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/ProfilePage', arguments: {
                      'user': MyUser.myUser,
                      'id_user': _authController.getUser.uid,
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.indigo[200]),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          MyUser.myUser.firstName +
                              ' ' +
                              MyUser.myUser.secondName,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
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
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () {
            if (_currentIndex == 2)
              Navigator.of(context).pushNamed('/SearchFriendsPage');
            else if (_currentIndex == 1)
              Navigator.of(context).pushNamed('/StartChatPage');
            else
              Navigator.of(context).pushNamed('/ProfilePage', arguments: {
                'user': MyUser.myUser,
                'id_user': _authController.getUser.uid,
              });
          },
          child: Icon(
            _currentIndex == 1 || _currentIndex == 2 ? Icons.add : Icons.person,
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
      drawerScrimColor: Colors.indigo,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: FutureBuilder(
        future: _authController.getUserInfo(_authController.getUser.uid),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data.data());
            User user = User().fromMap(snapshot.data.data());
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
