import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';


class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 1;
  DocumentSnapshot lastDocument;

  AuthController _authController = AuthController();
  ChatController _chatsController = ChatController();
  NotificationApi _notificationController = NotificationApi();

  List<DocumentSnapshot> chats = [null, null];

  @override
  void initState() {
//    getChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _chatsController.getChats(
          id_user: MyUser.myUser.id,
          last: lastDocument,
          limit: documentLimit,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            chats = snapshot.data.docs;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return _chatBuilder(
                    context,
                    Group().fromMap(chats[index].data())
                      ..setId(chats[index].id));
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _chatBuilder(BuildContext context, Group group) {
    User user;
    return FutureBuilder(
      future: _authController.getUserInfo(
        _authController.getUser.uid == group.members[0]
            ? group.members[1]
            : group.members[0],
      ),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          user = User().fromMap(snapshot.data.data()).setId(snapshot.data.id);
          return ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ImageView(
                        user.img != null ? user.img : ConstValues.userImage)));
              },
              // child: Hero(
              //   tag: user.img != null ? user.img : ConstValues.userImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: Image.asset(ConstValues.userImage),
                  ),
                  imageUrl: user.img != null ? user.img : ConstValues.userImage,
                  fit: BoxFit.cover,
                  width: 57,
                  height: 57,
                ),
              ),
              // ),
            ),
            title: Text(user.firstName + ' ' + user.secondName),
            subtitle: Text(Languages.translate(
              context,
              user.tag,
            )),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/ChatRoomPage',
                arguments: {
                  'user': user,
                  'group': group,
                },
              );
            },
            trailing: StreamBuilder(
                stream:
                _notificationController.getUnreadGroupNotificationsCount(
                  id_user: MyUser.myUser.id,
                  id_group: group.id,
                  type: 'chatsNotificationsCount',
                ),
                builder: (context, snapshot) {
                  int messageCount = 0;
                  if (snapshot.hasData && snapshot.data.data() != null) {
                    messageCount = snapshot.data.data()['count'];
                    print(messageCount);
                  }
                  return  Badge(
                    showBadge: messageCount != 0,
                    badgeColor: Theme.of(context).accentColor,
                    badgeContent: Text(
                      messageCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    position: BadgePosition.topStart(top: 0, start: -10),
                    child: Container(
                      width: 15,
                      height: 15,
                    ),
                  );
                }),
          );
        }
        return UserPlaceholder();
      },
    );
  }

  getChats() async {
    if (!hasMore) {
      print('No More chats');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _chatsController
        .getChats(
      id_user: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('chats');
      print(value.docs.length);
      setState(() {
        chats.insertAll(chats.length - 1, value.docs);
        isLoading = false;
        if (value.docs.length < documentLimit)
          hasMore = false;
        else
          lastDocument = value.docs.last;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
