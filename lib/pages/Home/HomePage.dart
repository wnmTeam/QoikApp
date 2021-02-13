import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/Home/tabs/FriendsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/GroupsChatsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/HomeTabView.dart';
import 'package:stumeapp/pages/Home/tabs/LibraryTabView.dart';
import 'package:stumeapp/pages/Home/widgets/FABwithBottomAppBar.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

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
  NotificationApi _notificationApi = NotificationApi();

  @override
  void initState() {
    _currentIndex = 1;
    _getUserInfo();
    _notificationApi.requestNotificationPermissions();
    _notificationApi.saveDeviceToken(_authController.getUser.uid);
    _authController.recordEnter();
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

  List<Link> link = new List();

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
          Badge(
            badgeContent: Text(
              '3',
              style: TextStyle(color: Colors.white),
            ),
            position: BadgePosition.topStart(top: 5, start: 5),
            child: IconButton(
              onPressed: () {
                Toast.show("Coming soon", context,
                    textColor: Colors.white,
                    backgroundColor: ConstValues.accentColor,
                    duration: Toast.LENGTH_LONG);
              },
              icon: Icon(
                CupertinoIcons.bell_solid,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/ChatsPage');
            },
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: InkWell(
                onTap: () {
                  if (!loading)
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
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Center(
                          //TODO: Change the placeHolder
                          child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                        ),
                        imageUrl: !loading && MyUser.myUser.img != null
                            ? MyUser.myUser.img
                            : ConstValues.userImage,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              )),
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
            text: Languages.translate(
              context,
              'home',
            ),
          ),
          FABBottomAppBarItem(
            iconData: Icons.chat,
            text: Languages.translate(
              context,
              'groups',
            ),
          ),
          FABBottomAppBarItem(
            iconData: Icons.group,
            text: Languages.translate(
              context,
              'friends',
            ),
          ),
          FABBottomAppBarItem(
            iconData: CupertinoIcons.book_solid,
            text: Languages.translate(
              context,
              'library',
            ),
//            svgIcon: 'assets/lib.svg',
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          backgroundColor: ConstValues.firstColor,
          heroTag: _currentIndex == 2 ? "search" : "profile",
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
        child: FutureBuilder(
            future: _authController.getLinks(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data);
                getLinks(snapshot.data);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      DrawerHeader(
                        child: Container(),
                      ),
                      ListTile(
                        title: Text(Languages.translate(
                          context,
                          'my_profile',
                        )),
                        leading: Icon(Icons.person_outline),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/ProfilePage',
                            arguments: {
                              'user': MyUser.myUser,
                              'id_user': _authController.getUser.uid,
                            },
                          );
                        },
                      ),
                      ListTile(
                        title: Text(Languages.translate(
                          context,
                          'setting',
                        )),
                        leading: Icon(Icons.settings_outlined),
                        onTap: () {
                          Navigator.pushNamed(context, "/Settings");
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text(link[0].title),
                        leading: Icon(link[0].icon),
                        onTap: () async => {
                          if (link[0].url != null)
                            {
                              await launch(link[0].url)
                                  .then((value) => print('url  ' + link[0].url))
                            }
                          else
                            {throw 'cant launch url'}
                        },
                      ),
                      ListTile(
                        title: Text(link[1].title),
                        leading: Icon(link[1].icon),
                        onTap: () async => {
                          if (link[1].url != null)
                            {
                              await launch(link[1].url)
                                  .then((value) => print('url  ' + link[1].url))
                            }
                          else
                            {throw 'cant launch url'}
                        },
                      ),
                      ListTile(
                        title: Text(link[2].title),
                        leading: Icon(link[2].icon),
                        onTap: () async => {
                          if (link[2].url != null)
                            {
                              await launch(link[2].url)
                                  .then((value) => print('url  ' + link[2].url))
                            }
                          else
                            {throw 'cant launch url'}
                        },
                      ),
                      ListTile(
                        title: Text(link[3].title),
                        leading: Icon(link[3].icon),
                        onTap: () async => {
                          if (link[3].url != null)
                            {
                              await launch(link[3].url)
                                  .then((value) => print('url  ' + link[3].url))
                            }
                          else
                            {throw 'cant launch url'}
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          Languages.translate(
                            context,
                            'log_out',
                          ),
                          style: TextStyle(color: Colors.red),
                        ),
                        leading: Icon(Icons.logout, color: Colors.red),
                        onTap: () {
                          _authController.logOut();
                        },
                      )
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerHeader(
                      child: Container(),
                    ),
                    ListTile(
                      title: Text(Languages.translate(
                        context,
                        'my_profile',
                      )),
                      leading: Icon(Icons.person_outline),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/ProfilePage',
                          arguments: {
                            'user': MyUser.myUser,
                            'id_user': _authController.getUser.uid,
                          },
                        );
                      },
                    ),
                    ListTile(
                      title: Text(Languages.translate(
                        context,
                        'setting',
                      )),
                      leading: Icon(Icons.settings_outlined),
                      onTap: () {
                        Navigator.pushNamed(context, "/Settings");
                      },
                    ),
                    Divider(),
                    CircularProgressIndicator(),
                    Divider(),
                    ListTile(
                      title: Text(
                        Languages.translate(
                          context,
                          'log_out',
                        ),
                        style: TextStyle(color: Colors.red),
                      ),
                      leading: Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        _authController.logOut();
                      },
                    )
                  ],
                ),
              );
            }),
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

  getLinks(links) {
    link.clear();

    link.add(new Link(
      icon: Icons.error_outline,
      title: Languages.translate(
        context,
        'about',
      ),
      url: links['about'],
    ));
    link.add(new Link(
        title: Languages.translate(
          context,
          'faq',
        ),
        icon: Icons.help_outline,
        url: links['faq']));
    link.add(new Link(
        title: Languages.translate(
          context,
          'join_us',
        ),
        icon: Icons.add_circle_outline,
        url: links['join_us']));
    link.add(new Link(
      title: Languages.translate(
        context,
        'privacy',
      ),
      icon: Icons.privacy_tip_outlined,
      url: links['privacy'],
    ));
  }
}

class Link {
  String url;
  String title;
  IconData icon;

  Link({this.url, this.title, this.icon});
}
