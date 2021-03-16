import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/FriendsController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';

class FriendsPage extends StatefulWidget {
  final User user;

  FriendsPage({this.user});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  FriendsController _friendsController = FriendsController();

  List<DocumentSnapshot> friends = [null, null, null];

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(context, "friends")),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          if (index == 0)
            return SizedBox(
              height: 10,
            );
          else if (index == friends.length - 2)
            return SizedBox(
              height: 0,
            );
          else if (index == friends.length - 1) {
            if (isLoading)
              return Center(child: CircularProgressIndicator());
            else if (hasMore)
              return FlatButton(
                onPressed: () {
                  getFriends();
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
    );
  }

  getFriends() async {
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
      id: widget.user.id,
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
  final String id;

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
            try {
              user = User().fromMap(snapshot.data)..setId(widget.id);
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      child: Image.asset(ConstValues.userImage),
                    ),
                    imageUrl:
                        user.img != null ? user.img : ConstValues.userImage,
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
                ),
              );
            } catch (e) {
              return Container();
            }
          }
          return UserPlaceholder();
        });
  }
}
