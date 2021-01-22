import 'package:flutter/material.dart';
import 'package:stumeapp/pages/ChatRoom/ChatRoomPage.dart';
import 'package:stumeapp/pages/ChatRoom/ChatsPage.dart';
import 'package:stumeapp/pages/ChatRoom/RoomPage.dart';
import 'package:stumeapp/pages/Friends/MyFriendsPage.dart';
import 'package:stumeapp/pages/Friends/SearchFriends.dart';
import 'package:stumeapp/pages/Group/CreatGroupPage.dart';
import 'package:stumeapp/pages/Group/EditPostPage.dart';
import 'package:stumeapp/pages/Group/GroupPage.dart';
import 'package:stumeapp/pages/Group/SelectMembersPage.dart';
import 'package:stumeapp/pages/Group/StartChatPage.dart';
import 'package:stumeapp/pages/Group/WritePost.dart';
import 'package:stumeapp/pages/Library/BookViewerPage.dart';
import 'package:stumeapp/pages/Library/BooksLibraryPage.dart';
import 'package:stumeapp/pages/Profile/ChangePasswordPage.dart';
import 'package:stumeapp/pages/Profile/ProfilePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';

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
            builder: (_) => FriendsRequestsPage(
                  id_user: args['id_user'],
                ));
      case '/SelectMembers':
        return MaterialPageRoute(
            builder: (_) => SelectFriendsPage(
                  group: args['group'],
                  type: args['type'],
                ));
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

      case '/BookViewerPage':
        return MaterialPageRoute(
            builder: (_) => BookViewerPage(
                  id: args['id'],
                ));
      case '/BooksPage':
        return MaterialPageRoute(
            builder: (_) => BooksPage(
                  category: args['category'],
                ));
      case '/ProfilePage':
        return MaterialPageRoute(
            builder: (_) => ProfilePage(
                  user: args['user'],
                ));
      case '/ChatsPage':
        return MaterialPageRoute(builder: (_) => ChatsPage());
      case '/RoomPage':
        return MaterialPageRoute(
            builder: (_) => RoomPage(
                  id_user: args['id_user'],
                  user: args['user'],
                  group: args['group'],
                ));
      case '/ChangePasswordPage':
        return MaterialPageRoute(builder: (_) => ChangePasswordPage());
      case '/EditPostPage':
        return MaterialPageRoute(
            builder: (_) => EditPostPage(
                  post: args['post'],
                  group: args['group'],
                  editPost: args['editPost'],
                ));
    }
  }
}
