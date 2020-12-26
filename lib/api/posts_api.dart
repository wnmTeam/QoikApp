import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';

class PostsApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getPosts({
    int limit,
    DocumentSnapshot last,
    Group group,
  }) {
    CollectionReference reference;
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }

    reference = _firestore.collection(type).doc(group.name).collection('posts');

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

  Future createPost(Post post, Group group) {
    CollectionReference reference;
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }

    reference = _firestore.collection(type).doc(group.name).collection('posts');
    return reference.add(post.toMap());
  }

  Future createComment({Comment comment, String post_id, Group group}) async {
    CollectionReference reference;
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    await _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(post_id)
        .collection('comments')
        .add(comment.toMap());

    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(post_id)
        .update({'commentCount': FieldValue.increment(1)});
  }

  Future<QuerySnapshot> getComments({
    int limit,
    DocumentSnapshot last,
    Group group,
    String id_post,
  }) {
    CollectionReference reference;
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }

    reference = _firestore
        .collection(type)
        .doc(group.name)
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
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }

    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .orderBy(
          Comment.DATE,
        )
        .startAfter([DateTime.now()]).snapshots();
  }

  getPostChanges({String id_post, Group group}) {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .get();
  }

  Stream ifILikePost({String id_post, Group group, String id_user}) {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('likers')
        .doc(id_user)
        .snapshots();
  }

  setLike({String id_user, String id_post, Group group}) async {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    print('check like');
    DocumentSnapshot r = await _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('likers')
        .doc(id_user)
        .get();
    print(r.data());
    print('there like');
    if (r.data() != null) {
      await _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .collection('likers')
          .doc(id_user)
          .delete();

      print('start del like');
      return _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .set(
              {'likeCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    }

    print('no like');
    await _firestore
        .collection(type)
        .doc(group.name)
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
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .set({'likeCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  followPost({id_user, String id_post, Group group}) async {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    DocumentSnapshot r = await _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .get();
    if (r.data() != null) {
      await _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .collection('followers')
          .doc(id_user)
          .delete();

      return _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .set({'followCount': FieldValue.increment(-1)},
              SetOptions(merge: true));
    }

    await _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .set({
      'exists': 1,
    });
    print(id_post);

    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .set({'followCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  isFollowPost({Group group, String id_post, id_user}) {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('followers')
        .doc(id_user)
        .snapshots();
  }

  setLikeToComment(
      {String id_post, id_user, String id_comment, Group group}) async {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    DocumentSnapshot r = await _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .collection('likers')
        .doc(id_user)
        .get();
    if (r.data() != null) {
      await _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .collection('comments')
          .doc(id_comment)
          .collection('likers')
          .doc(id_user)
          .delete();

      return _firestore
          .collection(type)
          .doc(group.name)
          .collection('posts')
          .doc(id_post)
          .collection('comments')
          .doc(id_comment)
          .set(
              {'likeCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    }

    await _firestore
        .collection(type)
        .doc(group.name)
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
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .set({'likeCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  isLikeComment(
      {Group group, String id_post, String id_user, String id_comment}) {
    String type;
    switch (group.type) {
      case Group.TYPE_UNIVERSITY:
        type = 'universityGroups';
        break;
      case Group.TYPE_COLLEGE:
        type = 'collegeGroups';
        break;
      case Group.TYPE_CHAT:
        type = 'chatGroups';
        break;
    }
    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(id_post)
        .collection('comments')
        .doc(id_comment)
        .collection('likers')
        .doc(id_user)
        .snapshots();
  }
}
