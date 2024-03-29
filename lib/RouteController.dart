import 'package:flutter/material.dart';
import 'package:stumeapp/pages/ChatRoom/ChatsPage.dart';
import 'package:stumeapp/pages/ChatRoom/RoomInfoPage.dart';
import 'package:stumeapp/pages/ChatRoom/conversationPage.dart';
import 'package:stumeapp/pages/Friends/FriendsRequestsPage.dart';
import 'package:stumeapp/pages/Friends/FrindsPage.dart';
import 'package:stumeapp/pages/Friends/SearchByIdPage.dart';
import 'package:stumeapp/pages/Friends/SearchFriends.dart';
import 'package:stumeapp/pages/Group/CreatGroupPage.dart';
import 'package:stumeapp/pages/Group/EditPostPage.dart';
import 'package:stumeapp/pages/Group/GroupPage.dart';
import 'package:stumeapp/pages/Group/PostPage.dart';
import 'package:stumeapp/pages/Group/SelectMembersPage.dart';
import 'package:stumeapp/pages/Group/Widgets.dart';
import 'package:stumeapp/pages/Group/WritePost.dart';
import 'package:stumeapp/pages/Library/BookInfoPage.dart';
import 'package:stumeapp/pages/Library/BookViewerPage.dart';
import 'package:stumeapp/pages/Library/BooksLibraryPage.dart';
import 'package:stumeapp/pages/Library/PendingBooksBage.dart';
import 'package:stumeapp/pages/Library/UploadBookPage.dart';
import 'package:stumeapp/pages/Library/pdfViewerPage.dart';
import 'package:stumeapp/pages/Notification/NotificationsPage.dart';
import 'package:stumeapp/pages/Profile/ChangePasswordPage.dart';
import 'package:stumeapp/pages/Profile/ProfilePage.dart';
import 'package:stumeapp/pages/RegesterLogin/RegisterLoginPage.dart';
import 'package:stumeapp/pages/Settings/Settings.dart';

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
      case '/FriendsPage':
        return MaterialPageRoute(
            builder: (_) => FriendsPage(
                  user: args['user'],
                ));
      case '/SelectMembers':
        return MaterialPageRoute(
            builder: (_) => SelectFriendsPage(
                  group: args['group'],
                  type: args['type'],
                  image: args['image'],
                ));
      case '/CreateGroupPage':
        return MaterialPageRoute(builder: (_) => CreateGroupPage());
      case '/ChatRoomPage':
        return MaterialPageRoute(
            builder: (_) => ChatRoomPage(
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
                  section: args['section'],
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
            builder: (_) => ChatRoomPage.room(
                  userId: args['id_user'],
                  user: args['user'],
                  group: args['group'],
                  onUpdate: args['onUpdate'],
                  exitGroup: args['exitGroup'],
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

      case '/RoomInfoPage':
        return MaterialPageRoute(
            builder: (_) => RoomInfoPage(
                  group: args['group'],
                  onUpdate: args['onUpdate'],
                ));

      case '/Settings':
        return MaterialPageRoute(builder: (_) => Settings());
      case '/NotificationsPage':
        return MaterialPageRoute(builder: (_) => NotificationsPage());
      case '/UploadBookPage':
        return MaterialPageRoute(builder: (_) => UploadBookPage());
      case '/PostPage':
        return MaterialPageRoute(
            builder: (_) => PostPage(
                  group: args['group'],
                  post: args['post'],
                ));
      case '/PDFScreen':
        return MaterialPageRoute(
            builder: (_) => PDFScreen(
                  path: args['path'],
                ));
      case '/BookInfoPage':
        return MaterialPageRoute(
            builder: (_) => BookInfoPage(
                  book: args['book'],
                  type: args['type'],
                ));
      case '/PendingBooksPage':
        return MaterialPageRoute(builder: (_) => PendingBooksPage());
        case '/Code':
        return MaterialPageRoute(builder: (_) => Code());
      case '/SearchToTag':
        return MaterialPageRoute(
            builder: (_) => SearchToTag(
                  groupId: args['groupId'],
                ));
    }
  }
}
