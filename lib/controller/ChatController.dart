import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Message.dart';
import 'package:stumeapp/api/chats_api.dart';

class ChatController {
  ChatsApi api = ChatsApi();

  Future getMessages({String id_chat, int limit, DocumentSnapshot last}) {
    return api.getMessages(
      id_chat: id_chat,
      limit: limit,
      last: last,
    );
  }

  Future addMessage({Message message, String id_chat}) {
    return api.addMessage(
      message: message,
      id_chat: id_chat,
    );
  }

  getNewMessages({String id_chat}) {
    return api.getNewMessages(id_chat: id_chat);
  }


}
