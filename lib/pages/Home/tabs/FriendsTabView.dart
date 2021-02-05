import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';
import 'package:cached_network_image/cached_network_image.dart';


class FriendsTab extends StatefulWidget {
  @override
  _FriendsTabState createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> friends = [null, null, null];

  Future<void> refresh() {
    setState(() {
      friends = [null, null, null];
      hasMore = true;
      lastDocument = null;
    });
    getMyFriends();
    return Future.delayed(Duration(milliseconds: 1));
  }

  @override
  void initState() {
    getMyFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                if (index == 0)
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          elevation: 0,
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/MyFriendsPage',
                              arguments: {
                                'id_user': _authController.getUser.uid
                              },
                            );
                          },
                          color: Colors.grey[300],
                          child: Text(Languages.translate(
                            context,
                            'frind_requests',
                          )),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                    ],
                  );
                else if (index == friends.length - 2)
                  return SizedBox(
                    height: 30,
                  );
                else if (index == friends.length - 1) {
                  if (isLoading)
                    return Center(child: CircularProgressIndicator());
                  else if (hasMore)
                    return FlatButton(
                      onPressed: () {
                        getMyFriends();
                      },
                      child: Text(Languages.translate(
                        context,
                        'load_more',
                      )),
                    );
                  return Container();
                }
                return UserWidget(id: friends[index].id);
              },
            ),
          ),
        ],
      ),
    );
  }

  getMyFriends() async {
    if (!hasMore) {
      print('No More friends');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _friendsController
        .getFriends(
      id: MyUser.myUser.id,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('friends');
      print(value.docs.length);
      setState(() {
        friends.insertAll(friends.length - 2, value.docs);
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

class UserWidget extends StatefulWidget {
  String id;

  UserWidget({this.id});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  AuthController _authController = AuthController();

  User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authController.getUserInfo(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = User().fromMap(snapshot.data)..setId(widget.id);
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/ProfilePage',
                  arguments: {
                    'user': user,
                    'id_user': user.id,
                  },
                );
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    //TODO: Change the placeHolder
                    child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                  ),
                  imageUrl: user.img != null ? user.img : ConstValues.userImage,
                  fit: BoxFit.cover,
                  width: 57,
                  height: 57,
                ),
              ),
              title: Text(user.firstName + ' ' + user.secondName),
              subtitle: Text(
                user.university + ' | ' + user.college,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            );
          }
          return UserPlaceholder();
        });
  }
}
