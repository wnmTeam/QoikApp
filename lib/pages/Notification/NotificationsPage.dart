import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Notification.dart' as noti;
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  List<DocumentSnapshot> notifications = [null, null];

  NotificationApi _notificationsController = NotificationApi();

  Future<void> refresh() {
    setState(() {
      notifications = [
        null,
        null,
      ];
      hasMore = true;
      lastDocument = null;
    });
    getFriendRequests();
    return Future.delayed(Duration(milliseconds: 1));
  }

  @override
  void initState() {
    getFriendRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Languages.translate(
            context,
            'notifications',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            if (index == 0)
              return SizedBox(
                height: 30,
              );
            else if (index == notifications.length - 1) {
              if (isLoading)
                return Center(child: CircularProgressIndicator());
              else if (hasMore)
                return FlatButton(
                  onPressed: () {
                    getFriendRequests();
                  },
                  child: Text(Languages.translate(
                    context,
                    'load_more',
                  )),
                );
              return Container();
            }
            return RequestFriendWidget(
              noti.Notification().fromMap(notifications[index].data()),
            );
          },
        ),
      ),
    );
  }

  getFriendRequests() async {
    if (!hasMore) {
      print('No More requests');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _notificationsController
        .getNotifications(
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('noti');
      setState(() {
        notifications.insertAll(notifications.length - 1, value.docs);
        isLoading = false;

        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }
}

class RequestFriendWidget extends StatefulWidget {
  noti.Notification notification;

  RequestFriendWidget(this.notification);

  @override
  _RequestFriendWidgetState createState() => _RequestFriendWidgetState();
}

class _RequestFriendWidgetState extends State<RequestFriendWidget> {
  AuthController _authController = AuthController();

  User user;

  FriendsController _friendsController = FriendsController();
  ChatController _chatsController = ChatController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authController.getUserInfo(widget.notification.idSender),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data)
            ..setId(widget.notification.idSender);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            onTap: () {
              switch (widget.notification.type) {
                case 'send_friend_request':
                  Navigator.pushNamed(context, '/MyFriendsPage');
                  break;
                case 'accept_friend_request':
                  Navigator.of(context).pushNamed(
                      '/ProfilePage',
                      arguments: {
                      'user': user,
                      'id_user': user.id,
                      },);
                  break;
              }
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child: CachedNetworkImage(
                placeholder: (context, url) => Center(
                  //TODO: Change the placeHolder
                  child: Image.asset(ConstValues.userImage),
                ),
                imageUrl: user.img != null ? user.img : ConstValues.userImage,
                fit: BoxFit.cover,
                width: 45,
                height: 45,
              ),
            ),
            title: Text(user.firstName +
                ' ' +
                user.secondName +
                " " +
                Languages.translate(
                  context,
                  widget.notification.type,
                )),
          );
        }
        return UserPlaceholder();
      },
    );
  }

  String getChatID() {
    List l = [user.id, _authController.getUser.uid];
    l.sort();

    return l[0] + l[1];
  }
}