import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/api/auth.dart';
import 'package:stumeapp/api/posts_api.dart';

class PostsController {
  PostsApi api = PostsApi();
  Auth auth = Auth();

  Future getPosts({int limit, DocumentSnapshot last, String groupId}) {
    return api.getPosts(
      limit: limit,
      last: last,
      groupId: groupId,
    );
  }

  Future createPost(
      String text, List<File> images, List<File> files, String groupId) {
    return api.createPost(
      text,
      images,
      files,
      groupId,
    );
  }

  Future<void> createComment(
      {String text, Post post, File image, File file, Group group}) {
    api.createComment(
      comment: Comment(
        text: text,
        idOwner: auth.getUser.uid,
        likeCount: 0,
        date: DateTime.now(),
      ),
      image: image,
      file: file,
      post: post,
      groupId: group.id,
    );
  }

  Future<QuerySnapshot> getComments(
      {int limit, DocumentSnapshot last, Group group, String postId}) {
    return api.getComments(
      limit: limit,
      last: last,
      groupId: group.id,
      postId: postId,
    );
  }

  Stream getNewComments({
    String postId,
    Group group,
  }) =>
      api.getNewComments(
        postId: postId,
        group: group,
      );

  getPostChanges({String postId, Group group}) => api.getPostChanges(
        postId: postId,
        group: group,
      );

  Future getMorePostInfo({Post post, Group group}) async {
    DocumentSnapshot d = await auth.getUserInfo(post.idOwner);
  }

  isLikePost({userId, Group group, String postId}) =>
      api.ifILikePost(group: group, postId: postId, userId: userId);

  Future setLike({userId, Group group, String postId}) =>
      api.setLike(userId: userId, postId: postId, group: group);

  followPost({userId, Group group, String postId}) =>
      api.followPost(userId: userId, postId: postId, group: group);

  isFollowPost({userId, Group group, String postId}) =>
      api.isFollowPost(group: group, postId: postId, userId: userId);

  setLikeToComment({userId, Group group, String postId, String commentId}) =>
      api.setLikeToComment(
        postId: postId,
        userId: userId,
        commentId: commentId,
        group: group,
      );

  isLikeComment(
          {String userId, Group group, String postId, String commentId}) =>
      api.isLikeComment(
        group: group,
        postId: postId,
        userId: userId,
        commentId: commentId,
      );

  Future addPoint({String groupId, Comment comment, Post post}) {
    return api.addPoint(
      groupId: groupId,
      comment: comment,
      post: post,
    );
  }

  deletePost({String groupId, String postId}) {
    return api.deletePost(
      groupId: groupId,
      postId: postId,
    );
  }

  updatePost({String groupId, String postId, String text}) {
    return api.updatePost(
      postId: postId,
      groupId: groupId,
      text: text,
    );
  }

  deletePoint({String groupId, Comment comment, Post post}) {
    return api.deletePoint(
      groupId: groupId,
      comment: comment,
      post: post,
    );
  }

  getCommentChanges({String groupId, String postId, String id_comment}) {
    return api.getCommentChanges(
      groupId: groupId,
      postId: postId,
      commentId: id_comment,
    );
  }

  getPost({String groupId, String postId}) {
    return api.getPost(groupId: groupId, postId: postId);
  }

  Future deleteComment({String post_id, String comment_id, String group_id}) {
    return api.deleteComment(
      comment_id: comment_id,
      post_id: post_id,
      group_id: group_id,
    );
  }

  updateComment({String text, String comment_id, String post_id, String group_id}) {
    return api.updateComment(
      text: text,
      comment_id: comment_id,
      post_id: post_id,
      group_id: group_id,
    );
  }
}
