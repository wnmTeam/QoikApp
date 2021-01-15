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
          onTap: () {},
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
                              : _MessageBuilder(Message()
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
                                        _MessageBuilder(Message()
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
                    children: [
                      Expanded(
                        child: TextField(
                          textAlign: TextAlign.start,
                          controller: _messageController,
                          enableSuggestions: true,
                          // maxLines: null,
                          // minLines: null,
                          // expands: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 5.0),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                              hintText: "Type a message..."),
                        ),
                      ),
                      FlatButton(
                        child: Icon(
                          Icons.send,
                          color: Colors.indigo,
                        ),
                        onPressed: () {
                          if (_messageController.text.isEmpty) return;
                          _chatController.addMessage(
                            message: Message(
                              idOwner: _authController.getUser.uid,
                              text: _messageController.text,
                              date: DateTime.now(),
                            ),
                            id_chat: getChatID(),
                          );
                          _messageController.clear();
                        },
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

  _MessageBuilder(Message message) {
    if (message.idOwner == _authController.getUser.uid) {
      //Start my message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      color: Colors.black38,
                    ),
                    child: Text(
                      message.text,
                      textAlign: TextAlign.justify,
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  //TODO add message time
                  // Text(
                  //   message.date.toString(),
                  //   textAlign: TextAlign.justify,
                  //   maxLines: 100,
                  //   // overflow: TextOverflow.ellipsis,
                  //   style: TextStyle(color: Colors.red),
                  // ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(57),
              //TODO hide images
              child: 1 == 1
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: MyUser.myUser.img,
                      fit: BoxFit.cover,
                      width: 30,
                      height: 30,
                    )
                  : Container(
                      width: 30,
                      height: 30,
                    ),
            )
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
            ClipRRect(
              borderRadius: BorderRadius.circular(57),
              //TODO hide images
              child: 1 == 1
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      imageUrl: widget.user.img,
                      fit: BoxFit.cover,
                      width: 30,
                      height: 30,
                    )
                  : Container(
                      width: 30,
                      height: 30,
                    ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(0),
                      ),
                      color: Colors.black54,
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      //End other's message
    }
  }
}
