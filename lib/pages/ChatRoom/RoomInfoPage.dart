import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';


class RoomInfoPage extends StatefulWidget {
  Group group;
  Function onUpdate;

  RoomInfoPage({
    this.group,
    this.onUpdate,
  });

  @override
  _RoomInfoPageState createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  AuthController _authController = AuthController();
  ChatController _chatController = ChatController();

  bool isAdmin = false;

  @override
  void initState() {
    if (widget.group.admins.contains(MyUser.myUser.id)) isAdmin = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.person_add),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/SelectMembers',
                  arguments: {
                    'group': widget.group,
                    'type': 'add',
                  },
                );
                widget.onUpdate();
        },
      )
          : null,
      body: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: _authController.getUserInfo(widget.group.members[index]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  User user = User()
                      .fromMap(snapshot.data.data())
                      .setId(snapshot.data.id);
                  print(user.id);
                  return ListTile(
                    onTap: () {
                      if (widget.group.admins.contains(MyUser.myUser.id) &&
                          user.id != MyUser.myUser.id) {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0)),
                            ),
                            builder: (BuildContext context) {
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text(Languages.translate(
                                      context,
                                      'show_profile',
                                    )),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/ProfilePage',
                                        arguments: {
                                          'id_user': user.id,
                                          'user': user,
                                        },
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.person_remove),
                                    title: Text(Languages.translate(
                                      context,
                                      'remove',
                                    )),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(Languages.translate(
                                                context,
                                                'delete',
                                              )),
                                              content: Text(Languages.translate(
                                                context,
                                                'delete',
                                              ) +
                                                  " " +
                                                  user.firstName +
                                                  ' ' +
                                                  user.secondName +
                                                  ' ' +
                                                  Languages.translate(
                                                    context,
                                                    'from_room',
                                                  )),
                                              actions: [
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    Languages.translate(
                                                      context,
                                                      'cancel',
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                FlatButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context, 'delete');
                                                  },
                                                  child: Text(
                                                    Languages.translate(
                                                      context,
                                                      'delete',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).then((value) async {
                                        if (value == 'delete') {
                                          setState(() {
                                            widget.group.members
                                                .removeAt(index);
                                          });
                                          Navigator.pop(context);
                                          await _chatController
                                              .removeMemberFromRoom(
                                            id_user: user.id,
                                            id_room: widget.group.id,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ],
                              );
                            });
                      } else
                        Navigator.pushNamed(
                          context,
                          '/ProfilePage',
                          arguments: {
                            'id_user': user.id,
                            'user': user,
                          },
                        );
                    },
                    title: Row(
                      children: [
                        Text(user.firstName + ' ' + user.secondName),
                        widget.group.admins.contains(user.id)
                            ? Icon(
                          Icons.star,
                          color: Colors.grey,
                        )
                            : Container(),
                      ],
                    ),
                    subtitle: Text(Languages.translate(
                      context,
                      user.tag,
                    )),
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
                  );
                }
                return UserPlaceholder();
              });
        },
      ),
    );
  }
}
