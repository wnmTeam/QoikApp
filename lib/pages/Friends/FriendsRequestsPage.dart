import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class FriendsRequestsPage extends StatefulWidget {
  final String id_user;

  FriendsRequestsPage({this.id_user});

  @override
  _FriendsRequestsPageState createState() => _FriendsRequestsPageState();
}

class _FriendsRequestsPageState extends State<FriendsRequestsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();

  // AuthController _authController = AuthController();

  List<DocumentSnapshot> friendRequests = [];

  Future<void> refresh() {
    setState(() {
      friendRequests = [];
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
    print(friendRequests);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Languages.translate(
            context,
            'frind_requests',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: friendRequests.isEmpty
            ? Center(
                child: Text(
                  Languages.translate(context, "no_requests"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      index == 0
                          ? SizedBox(
                              height: 30,
                            )
                          : Container(),
                      RequestFriendWidget(friendRequests[index].id, () {
                        setState(() {
                          friendRequests.removeAt(index);
                        });
                      }),
                      // if (index == 0)
                      index == friendRequests.length - 1
                          ? isLoading
                              ? Center(child: CircularProgressIndicator())
                              : hasMore
                                  ? FlatButton(
                                      onPressed: () {
                                        getFriendRequests();
                                      },
                                      child: Text(Languages.translate(
                                        context,
                                        'load_more',
                                      )),
                                    )
                                  : Container()
                          : Container()
                    ],
                  );
                  // else
                  // if (index == friendRequests.length - 1) {
                  // if (isLoading)
                  // return Column(
                  // children: [
                  // RequestFriendWidget(friendRequests[index].id, () {
                  // setState(() {
                  // friendRequests.removeAt(index);
                  // });
                  // }),
                  // Center(child: CircularProgressIndicator()),
                  // ],
                  // );
                  // else if (hasMore)
                  // return Column(
                  // children: [
                  // RequestFriendWidget(friendRequests[index].id, () {
                  // setState(() {
                  // friendRequests.removeAt(index);
                  // });
                  // }),
                  // FlatButton(
                  // onPressed: () {
                  // getFriendRequests();
                  // },
                  // child: Text(Languages.translate(
                  // context,
                  // 'load_more',
                  // )),
                  // ),
                  // ],
                  // );
                  // return Column(
                  // children: [
                  // RequestFriendWidget(friendRequests[index].id, () {
                  // setState(() {
                  // friendRequests.removeAt(index);
                  // });
                  // }),
                  // Container(),
                  // ],
                  // );
                  // }
                  // return RequestFriendWidget(friendRequests[index].id, () {
                  // setState(() {
                  // friendRequests.removeAt(index);
                  // });
                  // });
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
    _friendsController
        .getFriendRequests(
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('reqs');
      print(value.docs.length);
      setState(() {
        friendRequests.addAll(value.docs);
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
  String id_sender;
  Function deleteRequest;

  RequestFriendWidget(this.id_sender, this.deleteRequest);

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
      future: _authController.getUserInfo(widget.id_sender),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            user = User().fromMap(snapshot.data)..setId(widget.id_sender);

            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {},
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(57),
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
              title: Text(user.firstName + ' ' + user.secondName),
              subtitle: Text(
                user.degree != User.DEGREE_HIGH_SCHOOL
                    ? user.university + ' | ' + user.college
                    : Languages.translate(
                        context,
                        'high school',
                      ),
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: FlatButton.icon(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: Icon(
                  Icons.person_add,
                  color: Colors.grey[700],
                ),
                label: Text(Languages.translate(
                  context,
                  'accept',
                )),
                onPressed: () async {
                  await _friendsController.acceptRequestFriend(
                      id_requestSender: user.id);
                  print(Languages.translate(
                    context,
                    'send_done',
                  ));

                  // Navigator.pushNamed(
                  //   context,
                  //   '/ProfilePage',
                  //   arguments: {
                  //     'id_user': user.id,
                  //     'user': user,
                  //   },
                  // );
                  widget.deleteRequest();
                },
              ),
            );
          } catch (e) {
            return Container();
          }
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
