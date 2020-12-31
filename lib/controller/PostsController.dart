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

  Future getPosts({int limit, DocumentSnapshot last, String id_group}) {
    return api.getPosts(
      limit: limit,
      last: last,
      id_group: id_group,
    );
  }

  Future createPost(String text, String id_group) {
    return api.createPost(
      text,
      id_group,
    );
  }

  Future<void> createComment({String text, String post_id, Group group}) {
    api.createComment(
      comment: Comment(
        text: text,
        idOwner: auth.getUser.uid,
        likeCount: 0,
        date: DateTime.now(),
      ),
      post_id: post_id,
      id_group: group.id,
    );
  }

  Future<QuerySnapshot> getComments(
      {int limit, DocumentSnapshot last, Group group, String id_post}) {
    return api.getComments(
      limit: limit,
      last: last,
      id_group: group.id,
      id_post: id_post,
    );
  }

  Stream getNewComments({
    String id_post,
    Group group,
  }) =>
      api.getNewComments(
        id_post: id_post,
        group: group,
      );

  getPostChanges({String id_post, Group group}) => api.getPostChanges(
        id_post: id_post,
        group: group,
      );

  Future getMorePostInfo({Post post, Group group}) async {
    DocumentSnapshot d = await auth.getUserInfo(post.idOwner);
  }

  isLikePost({id_user, Group group, String id_post}) =>
      api.ifILikePost(group: group, id_post: id_post, id_user: id_user);

  Future setLike({id_user, Group group, String id_post}) =>
      api.setLike(id_user: id_user, id_post: id_post, group: group);

  followPost({id_user, Group group, String id_post}) =>
      api.followPost(id_user: id_user, id_post: id_post, group: group);

  isFollowPost({id_user, Group group, String id_post}) =>
      api.isFollowPost(group: group, id_post: id_post, id_user: id_user);

  setLikeToComment({id_user, Group group, String id_post, String id_comment}) =>
      api.setLikeToComment(
        id_post: id_post,
        id_user: id_user,
        id_comment: id_comment,
        group: group,
      );

  isLikeComment(
          {String id_user, Group group, String id_post, String id_comment}) =>
      api.isLikeComment(
        group: group,
        id_post: id_post,
        id_user: id_user,
        id_comment: id_comment,
      );
}
