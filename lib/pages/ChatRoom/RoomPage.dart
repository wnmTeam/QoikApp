import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomPage extends StatefulWidget {
  String id_user;
  User user;
  Group group;

  RoomPage({this.id_user, this.user, this.group});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool isLoading = false;
  bool isLoadingMembers = false;
  bool hasMore = true;
  int documentLimit = 25;
  DocumentSnapshot lastDocument = null;

  ChatController _chatController = ChatController();
  AuthController _authController = AuthController();

  List<DocumentSnapshot> messages = [];
  List<DocumentSnapshot> newMessages = [];

  TextEditingController _messageController = TextEditingController();

  Size size;

  Map members = {};

  Stream _getMessages;

  @override
  void initState() {
    print('chat id');
    print(getChatID());
    _getMessages = _chatController.getNewMessages(id_chat: getChatID());
    getMembers();
    getMessages();
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
          title: Text(widget.group.name),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.indigo[200]),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
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
                )),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  child: Container(
                    width: size.width,
                    height: 64,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                              hintText: 'Type a message..'),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FloatingActionButton(
                            elevation: 0,
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
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
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

  getMembers() async {
    for (String id in widget.group.members) {
      var d = await _authController.getUserInfo(id);
      User user = User().fromMap(d.data())..setId(d.id);
      members[user.id] = user;
    }



    setState(() {
      isLoadingMembers = false;
    });
  }

  String getChatID() {
    List l = [widget.user.id, _authController.getUser.uid];
    l.sort();

    return l[0] + l[1];
  }

  _MessageBuilder(Message message) {
    if (message.idOwner == _authController.getUser.uid)
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
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
                    color: Colors.deepOrange,
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            members[message.idOwner].firstName +
                                members[message.idOwner].secondName,
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            message.text,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child:  Image.network(
                members[message.idOwner].img,
                fit: BoxFit.cover,
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      );
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(57),
            child:  Image.network(
              members[message.idOwner].img,
              fit: BoxFit.cover,
              width: 30,
              height: 30,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Column(
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
                  color: Colors.deepOrange[300],
                ),
                child:Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          members[message.idOwner].firstName +
                              members[message.idOwner].secondName,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          message.text,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
