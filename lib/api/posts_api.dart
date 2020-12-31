import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/api/auth.dart';

class PostsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Auth auth = Auth();

  Future getPosts({
    int limit,
    DocumentSnapshot last,
    String id_group,
  }) {
    CollectionReference reference;

    reference =
        _firestore.collection('groups').doc(id_group).collection('posts');

    if (last == null) {
      log(reference.path, name: 'reference');
      return reference
          .orderBy(
            'date',
            descending: true,
          )
          .limit(limit)
          .get();
    } else {
      return reference
          .orderBy(
            'date',
            descending: true,
          )
          .startAfterDocument(last)
          .limit(limit)
          .get();
    }
  }

  Future createPost(String text, String id_group) {
    CollectionReference reference;

    reference =
        _firestore.collection('groups').doc(id_group).collection('posts');
    return reference.add({
      Post.TEXT: text,
      Post.ID_OWNER: auth.getUser.uid,
      Post.LIKE_COUNT: 0,
      Post.COMMENT_COUNT: 0,
      Post.FOLLOW_COUNT: 0,
      Post.DATE: FieldValue.serverTimestamp(),
    });
  }

  Future createComment({Comment comment, String post_id, String id_group}) async {
    CollectionReference reference;
    reference =
        _firestore.collection('groups').doc(id_group).collection('posts').doc(post_id).collection('comments');
    await reference
        .add(comment.toMap());

    return _firestore
        .collection('groups')
        .doc(id_group)
        .collection('posts')
        .doc(post_id)
        .update({'commentCount': FieldValue.increment(1)});
  }

  Future<QuerySnapshot> getComments({
    int limit,
    DocumentSnapshot last,
    String id_group,
    String id_post,
  }) {
    CollectionReference reference;

    reference = _firestore
        .collection('groups')
        .doc(id_group)
        .collection('posts')
        .doc(id_post)
        .collection('comments');

    if (last == null) {
      log(reference.path, name: 'reference');
      return reference
          .orderBy(
            Comment.DATE,
            descending: true,
          )
          .limit(limit)
          .get();
    } else {
      return reference
          .orderBy(
            Comment.DATE,
            descending: true,
          )
          .startAfterDocument(last)
          .limit(limit)
          .get();
    }
  }

  getNewComments({String id_post, Group group, DocumentSnapshot last}) {

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .orderBy(
          Comment.DATE,
        )
        .startAfter([DateTime.now()]).snapshots();
  }

  getPostChanges({String id_post, Group group}) {

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .get();
  }

  Stream ifILikePost({String id_post, Group group, String id_user}) {

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('likers')
        .doc(id_user)
        .snapshots();
  }

  setLike({String id_user, String id_post, Group group}) async {

    print('check like');
    DocumentSnapshot r = await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('likers')
        .doc(id_user)
        .get();
    print(r.data());
    print('there like');
    if (r.data() != null) {
      await _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .collection('likers')
          .doc(id_user)
          .delete();

      print('start del like');
      return _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .set(
              {'likeCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    }

    print('no like');
    await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('likers')
        .doc(id_user)
        .set({
      'exists': 1,
    });
    print(id_post);
    print('start add like');

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .set({'likeCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  followPost({id_user, String id_post, Group group}) async {

    DocumentSnapshot r = await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .get();
    if (r.data() != null) {
      await _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .collection('followers')
          .doc(id_user)
          .delete();

      return _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .set({'followCount': FieldValue.increment(-1)},
              SetOptions(merge: true));
    }

    await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .set({
      'exists': 1,
    });
    print(id_post);

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .set({'followCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  isFollowPost({Group group, String id_post, id_user}) {

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .snapshots();
  }

  setLikeToComment(
      {String id_post, id_user, String id_comment, Group group}) async {

    DocumentSnapshot r = await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .collection('likers')
        .doc(id_user)
        .get();
    if (r.data() != null) {
      await _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .collection('comments')
          .doc(id_comment)
          .collection('likers')
          .doc(id_user)
          .delete();

      return _firestore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(id_post)
          .collection('comments')
          .doc(id_comment)
          .set(
              {'likeCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    }

    await _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .collection('likers')
        .doc(id_user)
        .set({
      'exists': 1,
    });

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .set({'likeCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  isLikeComment(
      {Group group, String id_post, String id_user, String id_comment}) {

    return _firestore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .collection('likers')
        .doc(id_user)
        .snapshots();
  }
}
