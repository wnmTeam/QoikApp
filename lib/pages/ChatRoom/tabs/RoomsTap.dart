import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stumeapp/localization.dart';


class RoomsTab extends StatefulWidget {
  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  ChatController _chatsController = ChatController();

  List<DocumentSnapshot> rooms = [null, null];

  @override
  void initState() {
    getRooms();
    super.initState();
  }

  Future<void> refresh() {
    setState(() {
      rooms = [null, null];
      hasMore = true;
      lastDocument = null;
    });
    getRooms();
    return Future.delayed(Duration(milliseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (con, index) {
            //TODO: remove first item
            if (index == 0)
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                leading: Icon(Icons.group),
                title: Text('Create Group'),
                onTap: () {
                  if(!_authController.isBan())
                  Navigator.pushNamed(context, '/CreateGroupPage');
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
                                  Navigator.pop(context,);
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
              );
            else if (index == rooms.length - 1) {
              if (isLoading)
                return Center(child: CircularProgressIndicator());
              else if (hasMore)
                return FlatButton(
                  onPressed: () {
                    getRooms();
                  },
                  child: Text('Loade More'),
                );
              return Container();
            }
            return _chatBuilder(
                con,
                Group().fromMap(rooms[index].data())..setId(rooms[index].id),
                index);
          },
        ),
      ),
    );
  }

  Widget _chatBuilder(BuildContext context, Group group, int index) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(57),
          child: CachedNetworkImage(
            placeholder: (context, url) => Center(
              //TODO: Change the placeHolder
              child: Image.asset(ConstValues.userImage),
//                    child: Container(),
            ),
            imageUrl: group.img != null ? group.img : ConstValues.userImage,
            fit: BoxFit.cover,
            width: 57,
            height: 57,
          ),
        ),
        title: Text(group.name),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/RoomPage',
            arguments: {
              'user': MyUser.myUser,
              'group': group,
              'onUpdate': () async {
                var d = await _chatsController.getRoom(id: group.id);
                setState(() {
                  rooms[index] = d;
                });
              },
              'exitGroup': () {
                setState(() async {
                  rooms.removeAt(index);
                });
              }
            },
          );
        });
  }

  getRooms() async {
    if (!hasMore) {
      print('No More Rooms');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _chatsController
        .getRooms(
      id_user: _authController.getUser.uid,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('rooms');
      setState(() {
        rooms.insertAll(rooms.length - 1, value.docs);
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
