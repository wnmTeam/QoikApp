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

  Future createComment({Comment comment, String post_id, Group group}) {
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
        .doc(post_id)
        .collection('comments');

    return _firestore
        .collection(type)
        .doc(group.name)
        .collection('posts')
        .doc(post_id)
        .update({'commentsCount': FieldValue.increment(1)});
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
        .snapshots();
  }
}
