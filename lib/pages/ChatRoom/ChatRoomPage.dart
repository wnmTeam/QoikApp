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

import '../../const_values.dart';
import '../../localization.dart';

class ChatRoomPage extends StatefulWidget {
  String id_user;
  User user;
  Group group;

  ChatRoomPage({this.id_user, this.user, this.group});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 25;
  DocumentSnapshot lastDocument = null;

  ChatController _chatController = ChatController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> messages = [];
  List<DocumentSnapshot> newMessages = [];

  TextEditingController _messageController = TextEditingController();

  bool creatingChat = true;

  Size size;

  Stream _getMessages;

  @override
  void initState() {
    if (widget.group != null) {
      setState(() {
        creatingChat = false;
      });
      getMessages();
    } else
      createChat();
    _getMessages = _chatController.getNewMessages(id_chat: getChatID());

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
          title: Text(widget.user.firstName + ' ' + widget.user.secondName),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(57),
            child: CachedNetworkImage(
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              imageUrl: widget.user.img,
              fit: BoxFit.cover,
              width: 38,
              height: 38,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
      ),
      body: !creatingChat
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
                                  child: Text('Load More'),
                                )
                              : _messageBuilder(Message()
                                  .fromMap(messages[i].data())
                                  .setId(messages[i].id)),
                        StreamBuilder(
                          stream: _getMessages,
                          builder: (_, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data.docs.length > 0) {
                              print(snapshot.data.docs[0].data());
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
                                onPressed: () {},
                              ),
                              Expanded(
                                child: TextField(
                                  maxLines: 5,
                                  minLines: 1,
                                  textAlign: TextAlign.start,
                                  controller: _messageController,
                                  enableSuggestions: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                                    border: InputBorder.none,
                                    hintText: Languages.translate(
                                        context, 'type_a_message'),
                                    hintStyle: TextStyle(
                                        color: ConstValues.firstColor),
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
                            id_chat: getChatID(),
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
    )
        .then((value) {
      print('messages');
      print(value.docs.length);
      setState(() {
        messages.remove(null);
        messages.addAll(value.docs);

        isLoading = false;
        try {
          lastDocument = messages.last;
        } catch (e) {}
        if (value.docs.length == documentLimit) messages.add(null);
      });
    });
  }

  String getChatID() {
    List l = [widget.user.id, _authController.getUser.uid];
    l.sort();

    return l[0] + l[1];
  }

  _messageBuilder(Message message) {
    if (message.idOwner == _authController.getUser.uid) {
      //Start my message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _message(message, false, ConstValues.firstColor, 0, 20, 20, 20),
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
            _image(widget.user.img, true),
            SizedBox(
              width: 5,
            ),
            _message(message, true, ConstValues.firstColor, 20, 20, 20, 0),
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
              padding: EdgeInsets.all(10),
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
                  Text(
                    message.text,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    message.date.hour.toString() +
                        ":" +
                        message.date.minute.toString(),
                    style: TextStyle(color: Colors.white54),
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
            ? CachedNetworkImage(
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: 30,
                height: 30,
              )
            : Container(
                width: 30,
                height: 30,
              ),
      );
}
