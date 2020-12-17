import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/api/auth.dart';
import 'package:stumeapp/api/posts_api.dart';
import 'package:stumeapp/controller/AuthController.dart';

class PostsController {
  PostsApi api = PostsApi();
  Auth auth = Auth();

  getPosts({int limit, DocumentSnapshot last, Group group}) {
    return api.getPosts(
      limit: limit,
      last: last,
      group: group,
    );
  }

  Future createPost(String text, Group group) {
    return api.createPost(
      Post(
        text: text,
        idOwner: auth.getUser.uid,
        likeCount: 0,
        commentCount: 0,
        date: DateTime.now(),
      ),
      group,
    );
  }

  Future<void> createComment({String text, String post_id, Group group}) =>
      api.createComment(
        comment: Comment(
          text: text,
          idOwner: auth.getUser.uid,
          likeCount: 0,
          date: DateTime.now(),
        ),
        post_id: post_id,
        group: group,
      );

  Future<QuerySnapshot> getComments(
      {int limit, DocumentSnapshot last, Group group, String id_post}) {
    return api.getComments(
      limit: limit,
      last: last,
      group: group,
      id_post: id_post,
    );
  }

  Stream getNewComments({String id_post, Group group,}) =>
      api.getNewComments(
        id_post: id_post,
        group: group,
      );
}
