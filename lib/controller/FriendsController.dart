import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/api/auth.dart';
import 'package:stumeapp/api/friends_api.dart';

class FriendsController {
  FriendsApi api = FriendsApi();
  Auth auth = Auth();

  getFriendRequests({int limit, DocumentSnapshot last}) =>
      api.getFriendRequests(
        limit: limit,
        last: last,
        id: auth.getUser.uid,
      );

  sendRequestFriend({id_sender, String id_receiver}) => api.sendRequestFriend(
        id_sender: id_sender,
        id_receiver: id_receiver,
      );

  getFriends({String id, int limit, DocumentSnapshot last}) => api.getFriends(
        id: id,
        limit: limit,
        last: last,
      );

  acceptRequestFriend({String id_requestSender}) => api.acceptRequestFriend(
        id: auth.getUser.uid,
        id_requestSender: id_requestSender,
      );

  getFriend({id_user, String id_friend}) {
    return api.getFriend(
      id_user: id_user,
      id_friend: id_friend,
    );
  }
}
