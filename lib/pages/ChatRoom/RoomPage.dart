import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../const_values.dart';
import '../../localization.dart';

class RoomPage extends StatefulWidget {
  String id_user;
  User user;
  Group group;
  Function onUpdate;
  Function exitGroup;

  RoomPage(
      {this.id_user, this.user, this.group, this.onUpdate, this.exitGroup});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  var first;

  bool getNew = false;

  bool isLoading = false;
  bool isLoadingMembers = false;
  bool hasMore = true;
  int documentLimit = 25;
  DocumentSnapshot lastDocument;

  ChatController _chatController = ChatController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> messages = [];
  List<DocumentSnapshot> newMessages = [];

  StorageController _storageController = StorageController();

  TextEditingController _messageController = TextEditingController();

  Size size;

  Map members = {};

  List<File> _images;

  bool iamOut = false;

  @override
  void initState() {
    getMembers();
    getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {Languages.translate(
              context,
              'group_info',
              ), Languages.translate(
                context,
                'exit_group',
              )}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/RoomInfoPage',
              arguments: {'group': widget.group},
            );
          },
          title: Text(widget.group.name,
              style: TextStyle(
                color: Colors.white,
              )),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white),
          ),
        ),
      ),
      body: !isLoading && !isLoadingMembers
          ? Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [
                        for (int i = messages.length - 1; i >= 0; i--)
                          messages[i] == null
                              ? FlatButton(
                                  onPressed: () {
                                    getMessages();
                                  },
                                  child: Text(Languages.translate(
                                    context,
                                    'load_more',
                                  )),
                                )
                              : _messageBuilder(Message()
                                  .fromMap(messages[i].data())
                                  .setId(messages[i].id)),
                        StreamBuilder(
                          stream: getNew
                              ? _chatController.getNewMessages(
                                  id_chat: widget.group.id,
                                  last: first,
                                  type: 'rooms')
                              : null,
                          builder: (_, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data.docs.length > 0) {
                              newMessages = snapshot.data.docs;
                            }
                            return Row(
                              children: [
                                Container(
                                  width: size.width,
                                  child: Column(
                                    children: [
                                      for (var message in newMessages)
                                        _messageBuilder(Message()
                                            .fromMap(message.data())
                                            .setId(message.id)),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                !iamOut?
                Container(
                  width: size.width,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35.0),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 5,
                                  color: Colors.grey)
                            ],
                          ),
                          child: Row(
                            children: [
                              // IconButton(
                              //     icon: Icon(
                              //       Icons.tag_faces,
                              //       color: ConstValues.firstColor,
                              //     ),
                              //     onPressed: () {}),
                              IconButton(
                                icon: Icon(Icons.photo_camera,
                                    color: ConstValues.firstColor),
                                onPressed: () async {
                                  _images = [];
                                  final pickedFile =
                                      await _storageController.getImage();
                                  if (pickedFile != null) {
                                    {
                                      _images.add(File(pickedFile.path));
                                      _chatController.addMessage(
                                        message: Message(
                                          idOwner: MyUser.myUser.id,
                                          images: [],
                                        ),
                                        id_receiver: widget.group.id,
                                        images: _images,
                                        id_chat: widget.group.id,
                                        type: 'rooms',
                                      );
                                    }
                                  }
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  maxLines: 5,
                                  minLines: 1,
                                  textAlign: TextAlign.start,
                                  controller: _messageController,
                                  enableSuggestions: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 0),
                                    border: InputBorder.none,
                                    hintText: Languages.translate(
                                        context, 'type_a_message'),
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),

                              // IconButton(
                              //   icon: Icon(Icons.attach_file,
                              //       color: ConstValues.firstColor),
                              //   onPressed: () {},
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        backgroundColor: ConstValues.firstColor,
                        onPressed: () {
                          if (_messageController.text.trim().isEmpty) return;
                          _chatController.addMessage(
                            message: Message(
                              idOwner: _authController.getUser.uid,
                              text: _messageController.text.trim(),
                            ),
                            id_receiver: widget.group.id,
                            images: [],
                            id_chat: widget.group.id,
                            type: 'rooms',
                          );
                          _messageController.clear();
                        },
                        child: Icon(
                          // Icons.keyboard_voice,
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ):Text(Languages.translate(
                  context,
                  'cant_send_messages',
                )),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  getMessages() async {
    if (!hasMore) {
      print('No More messages');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _chatController
        .getMessages(
      id_chat: widget.group.id,
      limit: documentLimit,
      last: lastDocument,
      type: 'rooms',
    )
        .then((value) {
      print('messages');
      print(value.docs.length);
      setState(() {
        messages.remove(null);

        messages.addAll(value.docs);
        if (!getNew) {
          if (messages.length == 0)
            first = null;
          else
            first = messages.first;
        }
        getNew = true;
        isLoading = false;
        try {
          lastDocument = messages.last;
        } catch (e) {}
        if (value.docs.length == documentLimit) messages.add(null);
      });
    });
  }

  getMembers() async {
    for (String id in widget.group.members) {
      if (id == MyUser.myUser.id)
        members[id] = MyUser.myUser;
      else {
        var d = await _authController.getUserInfo(id);
        User user = User().fromMap(d.data())..setId(d.id);
        members[user.id] = user;
      }
    }

    setState(() {
      isLoadingMembers = false;
    });
  }

  _messageBuilder(Message message) {
    if (message.idOwner == MyUser.myUser.id) {
      //Start my message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _message(message, false, ConstValues.secondColor, 0, 20, 20, 20),
            SizedBox(
              width: 5,
            ),
            _image(MyUser.myUser.img, true)
          ],
        ),
      );
      //End my message

    } else {
      //Start other's message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image(
                members[message.idOwner] != null
                    ? members[message.idOwner].img
                    : ' ',
                true),
            SizedBox(
              width: 5,
            ),
            _message(message, true, ConstValues.accentColor, 20, 20, 20, 0),
          ],
        ),
      );
      //End other's message
    }
  }

  _message(Message message, bool isSender, Color color, double x1, double x2,
          double x3, double x4) =>
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(x1),
                  bottomLeft: Radius.circular(x2),
                  bottomRight: Radius.circular(x3),
                  topLeft: Radius.circular(x4),
                ),
                color: color,
              ),
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  isSender
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            members[message.idOwner] != null
                                ? members[message.idOwner].firstName +
                                    ' ' +
                                    members[message.idOwner].secondName
                                : Languages.translate(
                              context,
                              'deleted_user',
                            ),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        )
                      : Container(
                          width: 1,
                        ),
                  if (message.text != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        message.text,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  SizedBox(
                    height: 1,
                  ),
                  if (message.images != null)
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: 5, top: !isSender ? 0 : 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(!isSender ? x1 : 0),
                          topLeft: Radius.circular(!isSender ? x4 : 0),
                        ),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Center(
                            child: Container(
                              width: size.width / 2,
                              height: size.width / 2,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          imageUrl: message.images.length > 0
                              ? message.images[0]
                              : ' ',
                          fit: BoxFit.cover,
                          width: size.width / 2,
                          height: size.width / 2,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      message.date.hour.toString() +
                          ":" +
                          message.date.minute.toString(),
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  _image(String imageUrl, bool firstMessage) => ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: firstMessage
            ? CachedNetworkImage(
          placeholder: (context, url) => Center(
            //TODO: Change the placeHolder
            child: Image.asset(ConstValues.userImage),
//                    child: Container(),
          ),
          imageUrl: imageUrl != null ? imageUrl : ConstValues.userImage,
          fit: BoxFit.cover,
          width: 57,
          height: 57,
        )
            : Container(
                width: 30,
                height: 30,
              ),
      );

  void handleClick(String value) {
    switch (value) {
      case 'Group Info':
        Navigator.pushNamed(
          context,
          '/RoomInfoPage',
          arguments: {'group': widget.group},
        );
        break;
      case 'Exit Group':
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(Languages.translate(
                  context,
                  'exit_group_q',
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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, 'delete');
                    },
                    child: Text(
                      Languages.translate(
                        context,
                        'exit',
                      ),
                    ),
                  ),
                ],
              );
            }).then((value) async {
          if (value == 'delete') {
            setState(() {
              iamOut = true;
            });
            _chatController.removeMemberFromRoom(
              id_user: MyUser.myUser.id,
              id_room: widget.group.id,
            );
            widget.exitGroup();

//            Navigator.pop(context);
          }
        });
        break;
    }
  }
}
