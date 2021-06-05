import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/main.dart';
import 'package:stumeapp/pages/Home/tabs/FriendsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/GroupsChatsTabView.dart';
import 'package:stumeapp/pages/Home/tabs/HomeTabView.dart';
import 'package:stumeapp/pages/Home/tabs/LibraryTabView.dart';
import 'package:stumeapp/pages/Home/widgets/FABwithBottomAppBar.dart';
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
  ChatController _chatsController = ChatController();

  // final FirebaseMessaging fbm = FirebaseMessaging.instance;
  final LibraryController _libraryController = LibraryController();

  String getChatID(id) {
    List l = [id, MyUser.myUser.id];
    l.sort();

    return l[0] + l[1];
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _getUserInfo();
    _notificationApi.saveDeviceToken(_authController.getUser.uid);
    _authController.recordEnter();
    tabViews = [
      HomeTab(Group()..setId('homeGroup')),
      GroupsChatsTab(),
      FriendsTab(),
      LibraryTab(),
    ];

    // fbm.requestPermission();
    // FirebaseMessaging.
    // fbm.configure(
    //   onMessage: (msg) {
    //     print(msg);
    //     return;
    //   },
    //   onLaunch: (msg) {
    //     print(msg);
    //     String type = msg['data']['type'];
    //     String id_sender = msg['data']['id_sender'];
    //
    //     switch (type) {
    //       case 'chats':
    //         var d = chatsController.getChat(getChatID(id_sender));
    //
    //         Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
    //           'group': Group().fromMap(d.data())..setId(d.id),
    //           'user': User().fromMap(d.data()),
    //         });
    //         break;
    //       case 'rooms':
    //         break;
    //       default:
    //         Navigator.pushNamed(
    //           context,
    //           '/NotificationsPage',
    //         );
    //     }
    //     return;
    //   },
    //   onResume: (msg) {
    //     print(msg);
    //     String type = msg['data']['type'];
    //     String id_sender = msg['data']['id_sender'];
    //
    //     switch (type) {
    //       case 'chats':
    //         var d = chatsController.getChat(getChatID(id_sender));
    //
    //         Navigator.pushNamed(context, '/ChatRoomPage', arguments: {
    //           'group': Group().fromMap(d.data())..setId(d.id),
    //           'user': User().fromMap(d.data()),
    //         });
    //         break;
    //       case 'rooms':
    //         break;
    //       default:
    //         Navigator.pushNamed(
    //           context,
    //           '/NotificationsPage',
    //         );
    //     }
    //     return;
    //   },
    // );
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

  double width;
  StorageController storageController = new StorageController();

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage message) {
        if (message != null) {
          _notificationRout(message: message);
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _createForgroundNotification(message: message);
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        await _notificationRout(message: message);
      });
    }
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/logo.svg',
          // width: 24,
          height: 36,
          color: ConstValues.iconsColor,
        ),
        centerTitle: false,
        titleSpacing: 5,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/store.svg',
              color: Colors.white,
              width: 25,
              height: 25,
            ),
            onPressed: () {},
          ),
          StreamBuilder(
              stream: !loading
                  ? _notificationApi.getUnreadNotificationsCount(
                      id_user: MyUser.myUser.id)
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.data() != null) {
                  // TODO add sound here
                  return Badge(
                    showBadge: snapshot.data['count'] != 0,
                    badgeColor: Theme.of(context).accentColor,
                    badgeContent: Text(
                      snapshot.data['count'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    position: BadgePosition.topStart(top: 8, start: 5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/NotificationsPage');
                      },
                      icon: Icon(
                        CupertinoIcons.bell_solid,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/NotificationsPage');
                  },
                  icon: Icon(
                    CupertinoIcons.bell_solid,
                    color: Colors.white,
                  ),
                );
              }),
          StreamBuilder(
              stream: !loading
                  ? _notificationApi.getUnreadGroupsNotificationsCount(
                      id_user: MyUser.myUser.id,
                      type: 'chatsNotificationsCount',
                    )
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // TODO add sound here
                  return Badge(
                    showBadge: snapshot.data.docs.length != 0,
                    badgeColor: Theme.of(context).accentColor,
                    badgeContent: Text(
                      snapshot.data.docs.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    position: BadgePosition.topStart(top: 8, start: 5),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.chat_bubble_2_fill,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/ChatsPage');
                      },
                    ),
                  );
                }
                return IconButton(
                  icon: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/ChatsPage');
                  },
                );
              }),
          // IconButton(
          //   icon: Icon(
          //     CupertinoIcons.chat_bubble_2_fill,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/ChatsPage');
          //   },
          // ),
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
                          child: Image.asset(ConstValues.userImage),
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
        loading: loading,
        backgroundColor: Theme.of(context).primaryColor,
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
            stream: null,
          ),
          FABBottomAppBarItem(
            iconData: Icons.chat,
            text: Languages.translate(
              context,
              'groups',
            ),
            stream: null,
          ),
          FABBottomAppBarItem(
            iconData: Icons.group,
            text: Languages.translate(
              context,
              'friends',
            ),
            stream: null,
          ),
          FABBottomAppBarItem(
            iconData: CupertinoIcons.book_solid,
            text: Languages.translate(
              context,
              'library',
            ),
            stream: _libraryController.getPendingBooksCount(),
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: _currentIndex == 0 &&
                MyUser.myUser != null &&
                MyUser.myUser.userTag == 'admin'
            ? FloatingActionButton(
                onPressed: () {
                  if (!_authController.isBan())
                    Navigator.of(context).pushNamed(
                      '/WritePostPage',
                      arguments: {
                        'group': Group()..setId('homeGroup'),
                      },
                    );
                  else
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(Languages.translate(
                              context,
                              'blocked',
                            )),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                                child: Text(
                                  Languages.translate(
                                    context,
                                    'ok',
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              )
            : FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                heroTag: _currentIndex == 2 ? "search" : "profile",
                onPressed: () {
                  if (_currentIndex == 2)
                    Navigator.of(context).pushNamed('/SearchFriendsPage');
                  else if (_currentIndex == 0) {
                    if (MyUser.myUser.userTag == 'admin')
                      Navigator.of(context).pushNamed(
                        '/WritePostPage',
                        arguments: {
                          'group': Group()..setId('homeGroup'),
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
                  } else if (_currentIndex == 3)
                    Navigator.of(context).pushNamed('/UploadBookPage');
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
                  _currentIndex == 2
                      ? Icons.add
                      : _currentIndex == 3
                          ? Icons.add
                          : Icons.person,
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
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // DrawerHeader(
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).primaryColor,
                    //   ),
                    //   curve: SawTooth(10),
                    //   duration: Duration(seconds: 2),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Navigator.of(context).pushNamed(
                    //         '/ProfilePage',
                    //         arguments: {
                    //           'user': MyUser.myUser,
                    //           'id_user': _authController.getUser.uid,
                    //         },
                    //       );
                    //     },
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         ClipRRect(
                    //           borderRadius: BorderRadius.circular(1000),
                    //           child: CachedNetworkImage(
                    //             placeholder: (context, url) => Center(
                    //               child: Image.asset(ConstValues.userImage),
                    //             ),
                    //             imageUrl: !loading && MyUser.myUser.img != null
                    //                 ? MyUser.myUser.img
                    //                 : ConstValues.userImage,
                    //             fit: BoxFit.cover,
                    //             width: width / 5,
                    //             height: width / 5,
                    //           ),
                    //         ),
                    //         Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               MyUser.myUser.firstName +
                    //                   ' ' +
                    //                   MyUser.myUser.secondName,
                    //               style: TextStyle(
                    //                 fontSize: width / ConstValues.fontSize_1,
                    //               ),
                    //             ),
                    //             Text(
                    //               MyUser.myUser.email,
                    //               style: TextStyle(
                    //                 color: Theme.of(context)
                    //                     .textTheme
                    //                     .bodyText1
                    //                     .color
                    //                     .withAlpha(150),
                    //                 fontSize: width / 40,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Stack(
                      children: [
                        UserAccountsDrawerHeader(
                          arrowColor: Theme.of(context).primaryColor,
                          // decoration: BoxDecoration(
                          //   color: Theme.of(context).canvasColor,
                          // ),
                          accountName: Text(
                            MyUser.myUser.firstName +
                                ' ' +
                                MyUser.myUser.secondName,
                            // style: TextStyle(
                            //   fontSize: width / ConstValues.fontSize_1,
                            // ),
                          ),
                          accountEmail: Text(
                            MyUser.myUser.email,
                            // style: TextStyle(
                            //   color: Theme.of(context)
                            //       .textTheme
                            //       .bodyText1
                            //       .color
                            //       .withAlpha(150),
                            //   fontSize: width / 40,
                            // ),
                          ),
                          currentAccountPicture: ClipRRect(
                            borderRadius: BorderRadius.circular(1000),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Center(
                                child: Image.asset(ConstValues.userImage),
                              ),
                              imageUrl: !loading && MyUser.myUser.img != null
                                  ? MyUser.myUser.img
                                  : ConstValues.userImage,
                              fit: BoxFit.cover,
                              width: width / 5,
                              height: width / 5,
                            ),
                          ),

                          onDetailsPressed: () {
                            Navigator.of(context).pushNamed(
                              '/ProfilePage',
                              arguments: {
                                'user': MyUser.myUser,
                                'id_user': _authController.getUser.uid,
                              },
                            );
                          },
                        ),
                        Positioned(
                          right: 15,
                          top: 50,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: DayNightSwitcherIcon(
                              isDarkModeEnabled:
                                  storageController.getTheme() == 'dark',
                              onStateChanged: (isDarkModeEnabled) {
                                setState(() async {
                                  if (isDarkModeEnabled) {
                                    await storageController.setTheme('dark');
                                    MyAppState.myAppState.setState(() {
                                      MyAppState.isDark = true;
                                    });
                                  } else {
                                    await storageController.setTheme('light');

                                    MyAppState.myAppState.setState(() {
                                      MyAppState.isDark = false;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    snapshot.hasData
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(link[0].title),
                                leading: Icon(link[0].icon),
                                onTap: () async => {
                                  if (link[0].url != null)
                                    {
                                      await launch(link[0].url).then((value) =>
                                          print('url  ' + link[0].url))
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
                                      await launch(link[1].url).then((value) =>
                                          print('url  ' + link[1].url))
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
                                      await launch(link[2].url).then((value) =>
                                          print('url  ' + link[2].url))
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
                                      await launch(link[3].url).then((value) =>
                                          print('url  ' + link[3].url))
                                    }
                                  else
                                    {throw 'cant launch url'}
                                },
                              ),
                            ],
                          )
                        : CircularProgressIndicator(),
                    Divider(),
                    // ListTile(
                    //   title: Text("More Info"),
                    //   leading: Icon(Icons.info_outline),
                    //   onTap: () {
                    //    showAboutDialog(
                    //        context: context,
                    //    applicationIcon:Icon(
                    //      Icons.face,
                    //      color: Theme.of(context).primaryColor,
                    //    size: width/5,),
                    //      applicationName: "Qoiq App",
                    //      applicationVersion: "2.0.0",
                    //      useRootNavigator: false,
                    //
                    //    );
                    //   },
                    // ),
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
      // drawerScrimColor: Te
      //       //     .of(context)
      //       //     .primaryColor,hem
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

  _notificationRout({RemoteMessage message}) async {
    Map data = message.data;
    print(data);
    switch (data['type']) {
      case 'chats':
        String id_sender = data['id_sender'];
        var d = await _chatsController.getChat(getChatID(id_sender));
        Group chat;
        User user;
        if (d.data() != null) {
          chat = Group().fromMap(d.data())..setId(d.id);
        }
        d = await _authController.getUserInfo(id_sender);
        if (d.data() != null) {
          user = User().fromMap(d.data())..setId(d.id);
        }

        Navigator.pushNamed(
          context,
          '/ChatRoomPage',
          arguments: {
            'user': user,
            'group': chat,
          },
        );
        break;

      default:
        Navigator.pushNamed(context, '/NotificationsPage');
    }
  }

  _createForgroundNotification({RemoteMessage message}) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ));
    }
  }
}

class Link {
  String url;
  String title;
  IconData icon;

  Link({this.url, this.title, this.icon});
}
