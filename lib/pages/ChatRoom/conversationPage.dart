import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_pick/emoji_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/api/notification_api.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/ChatController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/pages/ChatRoom/Emoji.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../const_values.dart';
import '../../localization.dart';

class ChatRoomPage extends StatefulWidget {
  final String userId;
  final User user;
  Group group;
  Function onUpdate;
  Function exitGroup;
  bool isRoom;

  ChatRoomPage({this.userId, this.user, this.group}) {
    isRoom = false;
  }

  ChatRoomPage.room(
      {this.userId, this.user, this.group, this.onUpdate, this.exitGroup}) {
    isRoom = true;
  }

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

  NotificationApi _notificationController = NotificationApi();

  bool creatingChat = true;

  List<File> _images = [];

  Size size;

  // Stream _getMessages;
  Widget chosenImages = Container();
  bool isLoadingMembers = true;
  Map members = {};
  bool iamOut = false;

  double emojiHeight = 0.0;

  bool showEmoji = true;
  List<String> _tabsName = Emoji.TABS_NAMES;
  List<dynamic> _tabsEmoji = Emoji.TABS_EMOJI;

  @override
  void initState() {
    if (widget.group != null) {
      setState(() {
        creatingChat = false;
      });
      if (widget.isRoom) {
        getMembers();
        getRoomMessages();
      } else {
        getMessages();
      }
    } else
      createChat();

    updateNotificationCount(
      id_group: widget.group.id,
      id_user: MyUser.myUser.id,
    );
    super.initState();
  }

  @override
  void dispose() {
    updateNotificationCount(
      id_group: widget.group.id,
      id_user: MyUser.myUser.id,
    );
    super.dispose();
  }

  @override
  void deactivate() {
    updateNotificationCount(
      id_group: widget.group.id,
      id_user: MyUser.myUser.id,
    );
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: widget.isRoom
            ? AppBar(
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: handleClick,
                    itemBuilder: (BuildContext context) {
                      return {
                        Languages.translate(
                          context,
                          'group_info',
                        ),
                        Languages.translate(
                          context,
                          'exit_group',
                        )
                      }.map((String choice) {
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
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(57),
                    child: GestureDetector(
                      onTap: () {},
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Center(
                          child: Image.asset(ConstValues.userImage),
                        ),
                        imageUrl: widget.group != null
                            ? widget.group.img
                            : ConstValues.userImage,
                        fit: BoxFit.cover,
                        width: 38,
                        height: 38,
                      ),
                    ),
                  ),
                ),
              )
            : AppBar(
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
                      imageUrl: widget.user != null
                          ? widget.user.img
                          : ConstValues.userImage,
                      fit: BoxFit.cover,
                      width: 38,
                      height: 38,
                    ),
                  ),
                ),
              ),
        body:
            // widget.isRoom ?
            widget.isRoom && !isLoading && !isLoadingMembers || !creatingChat
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
                                              widget.isRoom
                                                  ? getRoomMessages()
                                                  : getMessages();
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
                                            id_chat: widget.isRoom
                                                ? widget.group.id
                                                : getChatID(),
                                            last: first,
                                            type: widget.isRoom
                                                ? 'rooms'
                                                : 'chats')
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
                            child: widget.isRoom && iamOut
                                ? Text(Languages.translate(
                                    context,
                                    'cant_send_messages',
                                  ))
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    textDirection: TextDirection.ltr,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(0, 3),
                                                  blurRadius: 5,
                                                  color: Colors.grey)
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.photo_camera,
                                                    color:
                                                        ConstValues.firstColor),
                                                onPressed: () async {
                                                  final pickedFile =
                                                      await _storageController
                                                          .getImageFromCamera();
                                                  if (pickedFile != null) {
                                                    _images.add(
                                                        File(pickedFile.path));
                                                    setState(() {
                                                      chosenImages = Container(
                                                        height: 150,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              _images.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return sendImagePreview(
                                                                index);
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
                                                  controller:
                                                      _messageController,
                                                  enableSuggestions: true,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0,
                                                            horizontal: 0),
                                                    border: InputBorder.none,
                                                    hintText:
                                                        Languages.translate(
                                                      context,
                                                      'type_a_message',
                                                    ),
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  onTap: () {
                                                    if (emojiHeight != 0.0) {
                                                      setState(() {
                                                        emojiHeight = 0.0;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons.attach_file,
                                                      color: ConstValues
                                                          .firstColor),
                                                  onPressed: () async {
                                                    final pickedFile =
                                                        await _storageController
                                                            .getImage();
                                                    if (pickedFile != null) {
                                                      _images.add(File(
                                                          pickedFile.path));
                                                      setState(() {
                                                        chosenImages =
                                                            Container(
                                                          height: 150,
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                _images.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return sendImagePreview(
                                                                  index);
                                                            },
                                                          ),
                                                        );
                                                      });
                                                    }
                                                  }),
                                              if (showEmoji)
                                                IconButton(
                                                    icon: Icon(
                                                        Icons
                                                            .emoji_emotions_outlined,
                                                        color: ConstValues
                                                            .firstColor),
                                                    onPressed: () {
                                                      if (emojiHeight == 0.0) {
                                                        setState(() {
                                                          emojiHeight = 255.0;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          emojiHeight = 0.0;
                                                        });
                                                      }
                                                    }),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Container(
                                          color: ConstValues.firstColor,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              textDirection: TextDirection.ltr,
                                            ),
                                            onPressed: () {
                                              if (_images.isNotEmpty) {
                                                setState(() {
                                                  chosenImages = Container();
                                                });
                                              }

                                              if (_messageController.text
                                                      .trim()
                                                      .isEmpty &&
                                                  _images.isEmpty) return;
                                              _chatController.addMessage(
                                                message: Message(
                                                  idOwner: _authController
                                                      .getUser.uid,
                                                  text: _messageController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _messageController.text
                                                          .trim(),
                                                ),
                                                id_receiver: widget.isRoom
                                                    ? widget.group.id
                                                    : widget.user.id,
                                                id_chat: widget.isRoom
                                                    ? widget.group.id
                                                    : getChatID(),
                                                images: _images,
                                                type: widget.isRoom
                                                    ? 'rooms'
                                                    : 'chats',
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
                          Emojies(
                              tabsname: _tabsName,
                              tabsemoji: _tabsEmoji,
                              maxheight: emojiHeight,
                              inputtext: _messageController,
                              bgcolor: Colors.white),
                        ],
                      ),
                    ],
                  )
                : Center(child: CircularProgressIndicator())
        // : !creatingChat
        //     ? Stack(
        //         children: [
        //           Positioned(
        //             top: 0,
        //             left: 0,
        //             right: 0,
        //             bottom: 0,
        //             child: Image.asset(
        //               "assets/chat_bg.png",
        //               fit: BoxFit.fill,
        //             ),
        //           ),
        //           Column(
        //             children: [
        //               Expanded(
        //                 child: SingleChildScrollView(
        //                   reverse: true,
        //                   child: Column(
        //                     children: [
        //                       for (int i = messages.length - 1; i >= 0; i--)
        //                         messages[i] == null
        //                             ? FlatButton(
        //                                 onPressed: () {
        //                                   widget.isRoom?getRoomMessages():
        //                                   getMessages();
        //                                 },
        //                                 child: Text(
        //                                   Languages.translate(
        //                                     context,
        //                                     'load_more',
        //                                   ),
        //                                 ),
        //                               )
        //                             : _messageBuilder(Message()
        //                                 .fromMap(messages[i].data())
        //                                 .setId(messages[i].id)),
        //                       StreamBuilder(
        //                         stream: getNew
        //                             ? _chatController.getNewMessages(
        //                                 id_chat:  widget.isRoom? widget
        //                                     .group.id: getChatID(),
        //                                 last: first,
        //                                 type:  widget.isRoom?'rooms':'chats')
        //                             : null,
        //                         builder: (_, snapshot) {
        //                           if (snapshot.hasData &&
        //                               snapshot.data.docs.length > 0) {
        //                             newMessages = snapshot.data.docs;
        //                           }
        //                           return Row(
        //                             children: [
        //                               Container(
        //                                 width: size.width,
        //                                 child: Column(
        //                                   children: [
        //                                     for (var message in newMessages)
        //                                       _messageBuilder(Message()
        //                                           .fromMap(message.data())
        //                                           .setId(message.id)),
        //                                   ],
        //                                 ),
        //                               )
        //                             ],
        //                           );
        //                         },
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //               chosenImages,
        //               Container(
        //                 width: size.width,
        //                 padding: const EdgeInsets.all(2.0),
        //                 child: widget.isRoom && iamOut
        //                     ?Text(Languages
        //                     .translate(
        //                   context,
        //                   'cant_send_messages',
        //                 )):
        //                      Row(
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   textDirection: TextDirection.ltr,
        //                   children: [
        //                     Expanded(
        //                       child: Container(
        //                         decoration: BoxDecoration(
        //                           color: Colors.white,
        //                           borderRadius: BorderRadius.circular(10.0),
        //                           boxShadow: [
        //                             BoxShadow(
        //                                 offset: Offset(0, 3),
        //                                 blurRadius: 5,
        //                                 color: Colors.grey)
        //                           ],
        //                         ),
        //                         child: Row(
        //                           crossAxisAlignment: CrossAxisAlignment.end,
        //                           children: [
        //                             IconButton(
        //                               icon: Icon(Icons.photo_camera,
        //                                   color: ConstValues.firstColor),
        //                               onPressed: () async {
        //                                 final pickedFile =
        //                                     await _storageController
        //                                         .getImageFromCamera();
        //                                 if (pickedFile != null) {
        //                                   _images.add(File(pickedFile.path));
        //                                   setState(() {
        //                                     chosenImages = Container(
        //                                       height: 150,
        //                                       child: ListView.builder(
        //                                         scrollDirection:
        //                                             Axis.horizontal,
        //                                         itemCount: _images.length,
        //                                         itemBuilder:
        //                                             (context, index) {
        //                                           return sendImagePreview(
        //                                               index);
        //                                         },
        //                                       ),
        //                                     );
        //                                   });
        //                                 }
        //                               },
        //                             ),
        //                             Expanded(
        //                               child: TextField(
        //                                 maxLines: 5,
        //                                 minLines: 1,
        //                                 textAlign: TextAlign.start,
        //                                 controller: _messageController,
        //                                 enableSuggestions: true,
        //                                 decoration: InputDecoration(
        //                                   contentPadding:
        //                                   EdgeInsets.symmetric(
        //                                       vertical: 0, horizontal: 0),
        //                                   border: InputBorder.none,
        //                                   hintText: Languages.translate(
        //                                     context,
        //                                     'type_a_message',
        //                                   ),
        //                                   hintStyle:
        //                                   TextStyle(color: Colors.grey),
        //                                 ),
        //                                 onTap: () {
        //                                   if (emojiHeight != 0.0) {
        //                                     setState(() {
        //                                       emojiHeight = 0.0;
        //                                     });
        //                                   }
        //                                 },
        //                               ),
        //                             ),
        //                             IconButton(
        //                                 icon: Icon(Icons.attach_file,
        //                                     color: ConstValues.firstColor),
        //                                 onPressed: () async {
        //                                   final pickedFile =
        //                                       await _storageController
        //                                           .getImage();
        //                                   if (pickedFile != null) {
        //                                     _images
        //                                         .add(File(pickedFile.path));
        //                                     setState(() {
        //                                       chosenImages = Container(
        //                                         height: 150,
        //                                         child: ListView.builder(
        //                                           scrollDirection:
        //                                               Axis.horizontal,
        //                                           itemCount: _images.length,
        //                                           itemBuilder:
        //                                               (context, index) {
        //                                             return sendImagePreview(
        //                                                 index);
        //                                           },
        //                                         ),
        //                                       );
        //                                     });
        //                                   }
        //                                 }),
        //                             if (showEmoji)
        //                               IconButton(
        //                                   icon: Icon(
        //                                       Icons.emoji_emotions_outlined,
        //                                       color: ConstValues.firstColor),
        //                                   onPressed: () {
        //                                     if (emojiHeight == 0.0) {
        //                                       setState(() {
        //                                         emojiHeight = 255.0;
        //                                       });
        //                                     } else {
        //                                       setState(() {
        //                                         emojiHeight = 0.0;
        //                                       });
        //                                     }
        //                                   }),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                     SizedBox(width: 10),
        //                     ClipRRect(
        //                       borderRadius: BorderRadius.circular(100),
        //                       child: Container(
        //                         color: ConstValues.firstColor,
        //                         child: IconButton(
        //                           icon: Icon(
        //                             Icons.send,
        //                             color: Colors.white,
        //                             textDirection: TextDirection.ltr,
        //                           ),
        //                           onPressed: () {
        //                             if (_images.isNotEmpty) {
        //                               setState(() {
        //                                 chosenImages = Container();
        //                               });
        //                             }
        //
        //                             if (_messageController.text
        //                                     .trim()
        //                                     .isEmpty &&
        //                                 _images.isEmpty) return;
        //                             _chatController.addMessage(
        //                               message: Message(
        //                                 idOwner: _authController.getUser.uid,
        //                                 text: _messageController.text
        //                                         .trim()
        //                                         .isEmpty
        //                                     ? null
        //                                     : _messageController.text.trim(),
        //                               ),
        //                               id_receiver:widget.isRoom? widget
        //                                   .group.id : widget.user.id,
        //                               id_chat: widget.isRoom?widget.group
        //                                   .id:getChatID(),
        //                               images: _images,
        //                               type:widget.isRoom?'rooms': 'chats',
        //                             );
        //                             _images = [];
        //                             _messageController.clear();
        //                           },
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               Emojies(
        //                   tabsname: _tabsname,
        //                   tabsemoji: _tabsemoji,
        //                   maxheight: emojiHeight,
        //                   inputtext: _messageController,
        //                   bgcolor: Colors.white),
        //             ],
        //           ),
        //         ],
        //       )
        //     : Center(child: CircularProgressIndicator()),
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

  getRoomMessages() async {
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

  String getChatID() {
    List l = [widget.user.id, MyUser.myUser.id];
    l.sort();

    return l[0] + l[1];
  }

  _messageBuilder(Message message) {
    if (message.idOwner != _authController.getUser.uid) {
      //Start other's  message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image(
                widget.isRoom
                    ? members[message.idOwner] != null
                        ? members[message.idOwner].img
                        : ConstValues.userImage
                    : widget.user != null
                        ? widget.user.img
                        : ConstValues.userImage,
                true),
            SizedBox(
              width: 5,
            ),
            Directionality.of(context) == TextDirection.ltr
                ? _message(
                    message, false, ConstValues.chatSecondColor, 10, 10, 10, 0)
                : _message(
                    message, false, ConstValues.chatSecondColor, 0, 10, 10, 10),
          ],
        ),
      );
      //End other's message

    } else {
      //Start my message
      return Container(
        margin: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality.of(context) == TextDirection.ltr
                ? _message(
                    message, true, ConstValues.chatFirstColor, 0, 10, 10, 10)
                : _message(
                    message, true, ConstValues.chatFirstColor, 10, 10, 10, 0),
            SizedBox(
              width: 5,
            ),
            _image(MyUser.myUser.img, true),
          ],
        ),
      );
      //End my message
    }
  }

  _message(Message message, bool isSender, Color color, double x1, double x2,
      double x3, double x4) {
    String minute = message.date.minute.toString().length < 2
        ? "0" + message.date.minute.toString()
        : message.date.minute.toString();
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                widget.isRoom
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
                              color: !isSender ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      )
                    : SizedBox(
                        width: 1,
                      ),
                if (message.images != null)
                  chatImageBuilder(message.images, message.text != null),
                SizedBox(
                  height: 4,
                ),
                if (message.text != null)
                  // Text(
                  //   message.text,
                  //   style: TextStyle(
                  //       color: isSender ? Colors.white : Colors.black,
                  //       fontSize: 16),
                  // ),
                  Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      } else {
                        throw 'Could not launch $link';
                      }
                    },
                    linkStyle: TextStyle(
                      color: isSender ? Colors.blue[900] : Colors.blue,
                    ),
                    options: LinkifyOptions(humanize: false),
                    text: message.text,
                    style: TextStyle(
                        color: isSender ? Colors.white : Colors.black,
                        fontSize: 16),
                  ),
                SizedBox(
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    message.date.hour.toString() + ":" + minute,
                    style: TextStyle(
                      color: isSender ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _image(String imageUrl, bool firstMessage) => ClipRRect(
        borderRadius: BorderRadius.circular(57),
        //TODO hide images
        child: firstMessage
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageView(imageUrl != null
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
                  builder: (_) => ImageView.file(
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

  void handleClick(String value) {
    if (Languages.translate(
          context,
          'group_info',
        ) ==
        value)
      Navigator.pushNamed(
        context,
        '/RoomInfoPage',
        arguments: {'group': widget.group},
      );
    else if (Languages.translate(
          context,
          'exit_group',
        ) ==
        value)
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

  void updateNotificationCount({String id_group, String id_user}) {
    _notificationController.resetGroupNotificationsCount(
        id_user: id_user,
        id_group: id_group,
        type: widget.isRoom
            ? 'roomsNotificationsCount'
            : 'chatsNotificationsCount');
  }
}
