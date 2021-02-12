import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';

import '../../const_values.dart';
import '../../localization.dart';

class ChatRoomPage extends StatefulWidget {
  final String userId;
  final User user;
  Group group;

  ChatRoomPage({this.userId, this.user, this.group});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  var first;

  bool isLoading = false;
  bool getNew = false;
  bool hasMore = true;
  int documentLimit = 25;
  DocumentSnapshot lastDocument = null;

  ChatController _chatController = ChatController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> messages = [];
  List<DocumentSnapshot> newMessages = [];

  TextEditingController _messageController = TextEditingController();

  StorageController _storageController = StorageController();

  bool creatingChat = true;

  List<File> _images = [];

  Size size;

  Stream _getMessages;
  Widget chosenImages = Container();

  @override
  void initState() {
    if (widget.group != null) {
      setState(() {
        creatingChat = false;
      });
      getMessages();
    } else
      createChat();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.of(context).pushNamed('/ProfilePage', arguments: {
              'user': widget.user,
              'id_user': widget.user.id,
            });
          },
          title: Text(
            widget.user.firstName + ' ' + widget.user.secondName,
            style: TextStyle(color: Colors.white),
          ),
          // subtitle: Text(
          //   widget.user.enterCount.toString(),
          //   style: TextStyle(color: Colors.white),
          // ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(57),
            child: CachedNetworkImage(
              placeholder: (context, url) => Center(
                child: Image.asset(ConstValues.userImage),
              ),
              imageUrl: widget.user.img != null
                  ? widget.user.img
                  : ConstValues.userImage,
              fit: BoxFit.cover,
              width: 38,
              height: 38,
            ),
          ),
        ),
      ),
      body: !creatingChat
          ? Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    "assets/chat_bg.png",
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
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
                                      child: Text(
                                        Languages.translate(
                                          context,
                                          'load_more',
                                        ),
                                      ),
                                    )
                                  : _messageBuilder(Message()
                                      .fromMap(messages[i].data())
                                      .setId(messages[i].id)),
                            StreamBuilder(
                              stream: getNew
                                  ? _chatController.getNewMessages(
                                      id_chat: getChatID(),
                                      last: first,
                                      type: 'chats')
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
                    chosenImages,
                    Container(
                      width: size.width,
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 5,
                                      color: Colors.grey)
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.photo_camera,
                                        color: ConstValues.firstColor),
                                    onPressed: () async {
                                      final pickedFile =
                                          await _storageController
                                              .getImageFromCamera();
                                      if (pickedFile != null) {
                                        _images.add(File(pickedFile.path));
                                        setState(() {
                                          chosenImages = Container(
                                            height: 150,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _images.length,
                                              itemBuilder: (context, index) {
                                                return sendImagePreview(index);
                                              },
                                            ),
                                          );
                                        });
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
                                            vertical: 0, horizontal: 0),
                                        border: InputBorder.none,
                                        hintText: Languages.translate(
                                          context,
                                          'type_a_message',
                                        ),
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.attach_file,
                                          color: ConstValues.firstColor),
                                      onPressed: () async {
                                        final pickedFile =
                                        await _storageController.getImage();
                                        if (pickedFile != null) {
                                          _images.add(File(pickedFile.path));
                                          setState(() {
                                            chosenImages = Container(
                                              height: 150,
                                              child: ListView.builder(
                                                scrollDirection:
                                                Axis.horizontal,
                                                itemCount: _images.length,
                                                itemBuilder: (context, index) {
                                                  return sendImagePreview(
                                                      index);
                                                },
                                              ),
                                            );
                                          });
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: ConstValues.firstColor,
                              child: IconButton(
                                icon: Icon(
                                  // Icons.keyboard_voice,
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (_images.isNotEmpty) {
                                    setState(() {
                                      chosenImages = Container();
                                    });
                                  }

                                  if (_messageController.text.trim().isEmpty &&
                                      _images.isEmpty) return;
                                  _chatController.addMessage(
                                    message: Message(
                                      idOwner: _authController.getUser.uid,
                                      text:
                                          _messageController.text.trim().isEmpty
                                              ? null
                                              : _messageController.text.trim(),
                                    ),
                                    id_receiver: widget.user.id,
                                    id_chat: getChatID(),
                                    images: _images,
                                    type: 'chats',
                                  );
                                  _images = [];
                                  _messageController.clear();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  createChat() async {
    Group group = Group(
      members: [
        widget.user.id,
        _authController.getUser.uid,
      ],
      type: Group.TYPE_CHAT,
      name: '',
    ).setId(getChatID());
    await _chatController.createChat(
      group: group,
    );

    setState(() {
      widget.group = group;
      creatingChat = false;
    });
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
      id_chat: getChatID(),
      limit: documentLimit,
      last: lastDocument,
      type: 'chats',
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
        lastDocument = messages.last;
        if (value.docs.length == documentLimit) messages.add(null);
      });
    });
  }

  String getChatID() {
    List l = [widget.user.id, MyUser.myUser.id];
    l.sort();

    return l[0] + l[1];
  }

  _messageBuilder(Message message) {
    if (message.idOwner != _authController.getUser.uid) {
      //Start my message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality.of(context) == TextDirection.ltr
                ? _message(
                message,
                false,
                ConstValues.chatFirstColor,
                0,
                10,
                10,
                10)
                : _message(
                message,
                false,
                ConstValues.chatFirstColor,
                10,
                10,
                10,
                0),
            SizedBox(
              width: 5,
            ),
            _image(widget.user.img, true),
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
            _image(MyUser.myUser.img, true),
            SizedBox(
              width: 5,
            ),
            Directionality.of(context) == TextDirection.ltr
                ? _message(
                message,
                true,
                ConstValues.chatSecondColor,
                10,
                10,
                10,
                0)
                : _message(
                message,
                true,
                ConstValues.chatSecondColor,
                0,
                10,
                10,
                10)
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
                  if (message.images != null) chatImageBuilder(message
                      .images, message.text != null),
                  SizedBox(
                    height: 4,
                  ),
                  if (message.text != null)
                    Text(
                      message.text,
                      style: TextStyle(color: Colors.black, fontSize: 16),
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
                      style: TextStyle(color: Colors.black54),
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
        //TODO hide images
        child: firstMessage
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ImageView(imageUrl != null
                              ? imageUrl
                              : ConstValues.userImage)));
                },
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: Image.asset(ConstValues.userImage),
//                    child: Container(),
                  ),
                  imageUrl: imageUrl != null ? imageUrl : ConstValues.userImage,
                  fit: BoxFit.cover,
                  width: 30,
                  height: 30,
                ),
        )
            : Container(
          width: 30,
          height: 30,
        ),
  );

  Widget chatImageBuilder(List<dynamic> images, bool isWithText) {
    List<Widget> dd = new List();

    for (String image in images) {
      dd.add(GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ImageView(image)));
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ClipRRect(
            child: CachedNetworkImage(
              progressIndicatorBuilder: (context, url, progress) {
                int size = progress.totalSize;
                String strSize;
                if (progress.totalSize != null) {
                  strSize = size < 1024
                      ? size.toStringAsFixed(2) + " B"
                      : size < 1048576
                      ? (size / 1024).toStringAsFixed(2) + " KB"
                      : (size / 1048576.0).toStringAsFixed(2) + " MB";
                } else {
                  strSize = '';
                }
                return Center(
                  child: Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                            value: progress.progress,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black)),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            strSize,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              imageUrl: image,
              fit: BoxFit.cover,
              // width:isWithText?null: size.width / 2,
              width: size.width / 2,
              height: size.width / 2,
            ),
          ),
        ),
      ));
      dd.add(SizedBox(
        height: 2,
      ));
    }
    return Column(
      children: dd,
    );
  }

  Widget sendImagePreview(int index) {
    return Container(
      height: 150,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              print(_images[index].path);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ImageView.file(
                        image: _images[index],
                        isFile: true,
                      )));
            },
            child: Image.file(_images[index]),
          ),
          // Positioned(
          //     top: 0,
          //     right: 0,
          //     child: IconButton(
          //       color: Colors.white,
          //       icon: Icon(Icons.clear,
          //       color:Colors.red),
          //       onPressed: () {
          //         setState(() {
          //           _images.removeAt(index);
          //         });
          //
          //       },
          //     ))
        ],
      ),
    );
  }
}
