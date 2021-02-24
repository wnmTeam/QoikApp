import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Notification.dart' as noti;
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

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
    _notificationsController.resetNotificationsCount(id_user: MyUser.myUser.id);
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
      print(value.docs);
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
  PostsController _postsControler = PostsController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authController.getUserInfo(widget.notification.idSender),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data)
            ..setId(widget.notification.idSender);
          print(widget.notification.type);

          return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () async {
                switch (widget.notification.type) {
                  case 'send_friend_request':
                    Navigator.pushNamed(context, '/MyFriendsPage', arguments: {
                      'id_user': user.id,
                    });
                    break;
                  case 'accept_friend_request':
                    Navigator.of(context).pushNamed(
                      '/ProfilePage',
                      arguments: {
                        'user': user,
                        'id_user': user.id,
                      },
                    );
                    break;
                  case 'client_comments_posts':
                    var d = await _postsControler.getPost(
                      id_group: widget.notification.idGroup,
                      id_post: widget.notification.idPost,
                    );
                    Navigator.of(context).pushNamed(
                      '/PostPage',
                      arguments: {
                        'post': Post().fromMap(d.data())..setId(d.id),
                        'group': Group().setId(widget.notification.idGroup),
                      },
                    );
                    break;
                  case 'commentMyPost':
                    var d = await _postsControler.getPost(
                      id_group: widget.notification.idGroup,
                      id_post: widget.notification.idPost,
                    );
                    Navigator.of(context).pushNamed(
                      '/PostPage',
                      arguments: {
                        'post': Post().fromMap(d.data())..setId(d.id),
                        'group': Group().setId(widget.notification.idGroup),
                      },
                    );
                    break;
                }
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: Image.asset(ConstValues.userImage),
                  ),
                  imageUrl: user.img != null ? user.img : ConstValues.userImage,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
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
              subtitle: Row(
                children: [
                  Icon(
                    CupertinoIcons.calendar_today,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(widget.notification.getStringDate),
                ],
              ));
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
