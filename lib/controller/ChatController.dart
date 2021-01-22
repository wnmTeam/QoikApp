import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/api/chats_api.dart';

class ChatController {
  ChatsApi api = ChatsApi();

  Future getMessages({
    String id_chat,
    int limit,
    DocumentSnapshot last,
    String type,
  }) {
    return api.getMessages(
      id_chat: id_chat,
      limit: limit,
      last: last,
      type: type,
    );
  }

  Future addMessage({
    Message message,
    String id_chat,
    List<File> images,
    String type,
  }) {
    return api.addMessage(
      message: message,
      id_chat: id_chat,
      type: type,
    );
  }

  getNewMessages({
    String id_chat,
    last,
    String type,
  }) {
    return api.getNewMessages(
      id_chat: id_chat,
      last: last,
      type: type,
    );
  }

  getChats({String id_user, int limit, DocumentSnapshot last}) {
    return api.getChats(
      id_user: id_user,
      limit: limit,
      last: last,
    );
  }

  createChat({Group group}) {
    return api.createChat(group: group);
  }

  getRooms({id_user, int limit, DocumentSnapshot last}) {
    return api.getRooms(
      id: id_user,
      last: last,
      limit: limit,
    );
  }

  getChat(String chatID) {
    return api.getChat(chatID);
  }
}
