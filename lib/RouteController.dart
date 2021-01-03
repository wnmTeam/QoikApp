import 'package:flutter/material.dart';
import 'package:stumeapp/pages/ChatRoom/ChatRoomPage.dart';
import 'package:stumeapp/pages/Friends/MyFriendsPage.dart';
import 'package:stumeapp/pages/Group/CreatGroupPage.dart';
import 'package:stumeapp/pages/Group/GroupPage.dart';
import 'package:stumeapp/pages/Group/SelectMembersPage.dart';
import 'package:stumeapp/pages/Group/StartChatPage.dart';
import 'package:stumeapp/pages/ProfilePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'file:///C:/flutterApps/stume_app/lib/pages/Friends/SearchFriends.dart';
import 'file:///C:/flutterApps/stume_app/lib/pages/Group/WritePost.dart';
import 'StartingPage.dart';

class RouteController {
  static Route<dynamic> getRoute(RouteSettings settings) {
    final Map args = settings.arguments as Map;

    switch (settings.name) {
      case '/StartingPage':
        return MaterialPageRoute(builder: (_) => StartingPage());
      case '/RegisterLoginPage':
        return MaterialPageRoute(builder: (_) => RegisterLoginPage());
      case '/GroupPage':
        return MaterialPageRoute(builder: (_) => GroupPage(args['group']));
      case '/WritePostPage':
        return MaterialPageRoute(builder: (_) => WritePostPage(args['group']));
      case '/SearchFriendsPage':
        return MaterialPageRoute(builder: (_) => SearchFriendsPage());
      case '/MyFriendsPage':
        return MaterialPageRoute(
            builder: (_) => MyFriendsPage(
                  id_user: args['id_user'],
                ));
      case '/SelectMembers':
        return MaterialPageRoute(
            builder: (_) => SelectFriendsPage(group: args['group'], type: args['type'],));
      case '/CreateGroupPage':
        return MaterialPageRoute(builder: (_) => CreateGroupPage());
      case '/StartChatPage':
        return MaterialPageRoute(builder: (_) => StartChatPage());
      case '/ChatRoomPage':
        return MaterialPageRoute(
            builder: (_) => ChatRoomPage(
                  id_user: args['id_user'],
                  user: args['user'],
                  group: args['group'],
                ));
      case '/ProfilePage':
        return MaterialPageRoute(
            builder: (_) => ProfilePage(
                  id_user: args['id_user'],
                  user: args['user'],
                ));
    }
  }
}
