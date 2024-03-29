import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Notification.dart' as noti;
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/api/auth.dart';
import 'package:stumeapp/controller/StorageController.dart';

import 'notification_api.dart';

class PostsApi {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final StorageController _storageController = StorageController();
  NotificationApi _notificationApi = NotificationApi();

  Auth auth = Auth();

  Future getPosts({
    int limit,
    DocumentSnapshot last,
    String groupId,
    String order,
  }) {
    CollectionReference reference;

    reference =
        _fireStore.collection('groups').doc(groupId).collection('posts');

    if (last == null) {
      log(reference.path, name: 'reference');
      return reference
          .orderBy(
            Post.DATE,
            descending: true,
          )
          .limit(limit)
          .get();
    } else {
      return reference
          .orderBy(
            Post.DATE,
            descending: true,
          )
          .startAfterDocument(last)
          .limit(limit)
          .get();
    }
  }

  getPinnedPosts({String groupId}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .where(Post.IS_PIN, isEqualTo: true)
        .orderBy(Post.LAST_ACTIVE, descending: true)
        .get();
  }

  Future createPost(
      String text, List<File> images, List<File> files, String groupId) async {
    CollectionReference reference;

    reference =
        _fireStore.collection('groups').doc(groupId).collection('posts');
    DocumentReference ref = await reference.add({
      Post.TEXT: text,
      Post.ID_OWNER: auth.getUser.uid,
      Post.LIKE_COUNT: 0,
      Post.COMMENT_COUNT: 0,
      Post.FOLLOW_COUNT: 0,
      Post.COMMENT_POINTED: null,
      Post.DATE: FieldValue.serverTimestamp(),
      Post.LAST_ACTIVE: FieldValue.serverTimestamp(),
    });

    List imagesUrls = [];
    List filesUrls = [];
    int i = 0;
    for (File file in images) {
      String url = await _storageController.uploadPostImage(
        id_post: ref.id,
        id_group: groupId,
        nom: i.toString(),
        img: file,
      );
      imagesUrls.add(url);
      i++;
    }
    //--------------------------------
    for (File file in files) {
      String url = await _storageController.uploadPostFile(
        id_post: ref.id,
        id_group: groupId,
        nom: i.toString(),
        file: file,
      );
      print("File url $url");
      filesUrls.add(url);
      i++;
    }

    return ref.set({
      'images': FieldValue.arrayUnion(imagesUrls),
      'files': FieldValue.arrayUnion(filesUrls),
    }, SetOptions(merge: true));
  }

  Future createComment(
      {Comment comment,
      Post post,
      String groupId,
      File image,
      File file}) async {
    CollectionReference reference;
    reference = _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(post.id)
        .collection('comments');

    String imageUrl;
    if (image != null)
      imageUrl = await _storageController.uploadCommentImage(
        id_post: post.id,
        id_group: groupId,
        nom: "0",
        img: image,
      );
    //
    //TODO upload comment file
    // String fileUrl = await _storageController.uploadCommentFile(
    //   id_post: post.id,
    //   id_group: groupId,
    //   nom: "0",
    //   file: comment.file,
    // );

    WriteBatch b = _fireStore.batch();

    b.set(reference.doc(), {
      "id_owner": comment.idOwner,
      "text": comment.text,
      "date": comment.date,
      "likeCount": comment.likeCount,
      'image': imageUrl,
      "file": null,
      Comment.MENTIONS: comment.mentions,
    });

    // DocumentReference ref = await reference.add({
    //   "id_owner": comment.idOwner,
    //   "text": comment.text,
    //   "date": comment.date,
    //   "likeCount": comment.likeCount,
    //   'image': imageUrl,
    //   "file": null,
    //   Comment.MENTIONS: comment.mentions,
    // });

    b.set(
        _fireStore
            .collection('groups')
            .doc(groupId)
            .collection('posts')
            .doc(post.id),
        {Post.LAST_ACTIVE: FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    // await _fireStore
    //     .collection('groups')
    //     .doc(groupId)
    //     .collection('posts')
    //     .doc(post.id)
    //     .set({Post.LAST_ACTIVE: FieldValue.serverTimestamp()},
    //         SetOptions(merge: true));

    _notificationApi.sendMentionsNotifications(
      mentions: comment.mentions,
      idPost: post.id,
      idGroup: groupId,
      idSender: auth.getUser.uid,
    );

    _notificationApi.sendNotification(
        noti.Notification(
          type: 'commentPost',
          data: comment.text != null ? comment.text : ' ',
          idSender: comment.idOwner,
          idGroup: groupId,
          idPost: post.id,
        ),
        'notifications',
        id_group: groupId,
        id_post: post.id);

    if (post.idOwner != MyUser.myUser.id) {
      // await _notificationApi.subscribeToTopic(groupId + post.id);
      _notificationApi.sendNotification(
          noti.Notification(
            type: 'commentMyPost',
            data: comment.text != null ? comment.text : ' ',
            idSender: comment.idOwner,
            idReceiver: post.idOwner,
            idGroup: groupId,
            idPost: post.id,
          ),
          'notifications',
          id_group: groupId,
          id_post: post.id);
    }

    b.update(
        _fireStore
            .collection('groups')
            .doc(groupId)
            .collection('posts')
            .doc(post.id),
        {'commentCount': FieldValue.increment(1)});

    // return _fireStore
    //     .collection('groups')
    //     .doc(groupId)
    //     .collection('posts')
    //     .doc(post.id)
    //     .update({'commentCount': FieldValue.increment(1)});

    return b.commit();
  }

  Future<QuerySnapshot> getComments({
    int limit,
    DocumentSnapshot last,
    String groupId,
    String postId,
  }) {
    CollectionReference reference;

    reference = _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
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

  getNewComments({String postId, Group group, DocumentSnapshot last}) {
    return _fireStore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy(
          Comment.DATE,
          // descending: true,
        )
        .startAfter([DateTime.now()]).snapshots();
  }

  getPostChanges({String postId, Group group}) {
    return _fireStore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(postId)
        .get();
  }

  Stream ifILikePost({String postId, Group group, String userId}) {
    return _fireStore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(postId)
        .collection('likers')
        .doc(userId)
        .snapshots();
  }

  setLike({String userId, String postId, Group group}) async {
    // print('check like');
    return _fireStore.runTransaction((transaction) async {
      DocumentSnapshot r = await transaction.get(_fireStore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(postId)
          .collection('likers')
          .doc(userId));

      if (r.data() != null) {
        transaction.delete(_fireStore
            .collection('groups')
            .doc(group.id)
            .collection('posts')
            .doc(postId)
            .collection('likers')
            .doc(userId));

        print('start del like');
        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId),
            {'likeCount': FieldValue.increment(-1)},
            SetOptions(merge: true));
      } else {
        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId)
                .collection('likers')
                .doc(userId),
            {
              'exists': 1,
            });
        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId),
            {'likeCount': FieldValue.increment(1)},
            SetOptions(merge: true));
      }
    });
    // DocumentSnapshot r = await _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .collection('likers')
    //     .doc(userId)
    //     .get();
    // print(r.data());
    // print('there like');
    // if (r.data() != null) {
    //   await _fireStore
    //       .collection('groups')
    //       .doc(group.id)
    //       .collection('posts')
    //       .doc(postId)
    //       .collection('likers')
    //       .doc(userId)
    //       .delete();
    //
    //   print('start del like');
    //   return _fireStore
    //       .collection('groups')
    //       .doc(group.id)
    //       .collection('posts')
    //       .doc(postId)
    //       .set(
    //           {'likeCount': FieldValue.increment(-1)}, SetOptions(merge: true));
    // }

    // print('no like');
    // await _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .collection('likers')
    //     .doc(userId)
    //     .set({
    //   'exists': 1,
    // });
    // print(postId);
    // print('start add like');
    //
    // return _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .set({'likeCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  followPost({userId, String postId, Group group}) async {
    return _fireStore.runTransaction((transaction) async {
      DocumentSnapshot r = await transaction.get(_fireStore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(postId)
          .collection('followers')
          .doc(userId));

      if (r.data() != null) {
        transaction.delete(_fireStore
            .collection('groups')
            .doc(group.id)
            .collection('posts')
            .doc(postId)
            .collection('followers')
            .doc(userId));

        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId),
            {'followCount': FieldValue.increment(-1)},
            SetOptions(merge: true));
        await _notificationApi.unsubscribeFromTopic(group.id + postId);
      } else {
        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId)
                .collection('followers')
                .doc(userId),
            {
              'exists': 1,
            });

        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId),
            {'followCount': FieldValue.increment(1)},
            SetOptions(merge: true));

        await _notificationApi.subscribeToTopic(group.id + postId);
      }
    });

    // DocumentSnapshot r = await _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .collection('followers')
    //     .doc(userId)
    //     .get();
    // if (r.data() != null) {
    //   await _fireStore
    //       .collection('groups')
    //       .doc(group.id)
    //       .collection('posts')
    //       .doc(postId)
    //       .collection('followers')
    //       .doc(userId)
    //       .delete();
    //
    //   await _notificationApi.unsubscribeFromTopic(group.id + postId);
    //
    //   return _fireStore
    //       .collection('groups')
    //       .doc(group.id)
    //       .collection('posts')
    //       .doc(postId)
    //       .set({'followCount': FieldValue.increment(-1)},
    //           SetOptions(merge: true));
    // }

    // await _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .collection('followers')
    //     .doc(userId)
    //     .set({
    //   'exists': 1,
    // });
    // print(postId);
    // await _notificationApi.subscribeToTopic(group.id + postId);
    //
    // return _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .set({'followCount': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  isFollowPost({Group group, String postId, userId}) {
    return _fireStore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(postId)
        .collection('followers')
        .doc(userId)
        .snapshots();
  }

  setLikeToComment(
      {String postId, userId, String commentId, Group group}) async {
    // WriteBatch b = _fireStore.batch();

    return _fireStore.runTransaction((transaction) async {
      DocumentSnapshot r = await transaction.get(_fireStore
          .collection('groups')
          .doc(group.id)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('likers')
          .doc(userId));

      if (r.data() != null) {
        transaction.delete(_fireStore
            .collection('groups')
            .doc(group.id)
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('likers')
            .doc(userId));

        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .doc(commentId),
            {'likeCount': FieldValue.increment(-1)},
            SetOptions(merge: true));
      } else {
        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .doc(commentId)
                .collection('likers')
                .doc(userId),
            {
              'exists': 1,
            });

        transaction.set(
            _fireStore
                .collection('groups')
                .doc(group.id)
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .doc(commentId),
            {'likeCount': FieldValue.increment(1)},
            SetOptions(merge: true));
      }
    });

    // DocumentSnapshot r = await _fireStore
    //     .collection('groups')
    //     .doc(group.id)
    //     .collection('posts')
    //     .doc(postId)
    //     .collection('comments')
    //     .doc(commentId)
    //     .collection('likers')
    //     .doc(userId)
    //     .get();
    // if (r.data() != null) {
    //   b.delete(_fireStore
    //       .collection('groups')
    //       .doc(group.id)
    //       .collection('posts')
    //       .doc(postId)
    //       .collection('comments')
    //       .doc(commentId)
    //       .collection('likers')
    //       .doc(userId));
    //
    //   b.set(
    //       _fireStore
    //           .collection('groups')
    //           .doc(group.id)
    //           .collection('posts')
    //           .doc(postId)
    //           .collection('comments')
    //           .doc(commentId),
    //       {'likeCount': FieldValue.increment(-1)},
    //       SetOptions(merge: true));
    //
    //   return b.commit();
    // }

    // b.set(
    //     _fireStore
    //         .collection('groups')
    //         .doc(group.id)
    //         .collection('posts')
    //         .doc(postId)
    //         .collection('comments')
    //         .doc(commentId)
    //         .collection('likers')
    //         .doc(userId),
    //     {
    //       'exists': 1,
    //     });
    //
    // b.set(
    //     _fireStore
    //         .collection('groups')
    //         .doc(group.id)
    //         .collection('posts')
    //         .doc(postId)
    //         .collection('comments')
    //         .doc(commentId),
    //     {'likeCount': FieldValue.increment(1)},
    //     SetOptions(merge: true));

    // return b.commit();
  }

  isLikeComment({Group group, String postId, String userId, String commentId}) {
    return _fireStore
        .collection('groups')
        .doc(group.id)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('likers')
        .doc(userId)
        .snapshots();
  }

  Future addPoint({String groupId, Comment comment, Post post}) {
    print(post.id);
    print(comment.id);
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(post.id)
        .set(
      {'commentPointed': comment.id},
      SetOptions(merge: true),
    );
  }

  deletePost({String groupId, String postId}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  updatePost({String postId, String groupId, String text}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .set(
      {'text': text},
      SetOptions(
        merge: true,
      ),
    );
  }

  deletePoint({String groupId, Comment comment, Post post}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(post.id)
        .set(
      {'commentPointed': null},
      SetOptions(merge: true),
    );
  }

  getCommentChanges({String groupId, String postId, String commentId}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();
  }

  getPost({String groupId, String postId}) {
    return _fireStore
        .collection('groups')
        .doc(groupId)
        .collection('posts')
        .doc(postId)
        .get();
  }

  deleteComment({String comment_id, String post_id, String group_id}) {
    print(group_id);
    print(post_id);
    print(comment_id);
    WriteBatch b = _fireStore.batch();

    var d = _fireStore
        .collection('groups')
        .doc(group_id)
        .collection('posts')
        .doc(post_id);
    b.set(d, {Post.COMMENT_COUNT: FieldValue.increment(-1)},
        SetOptions(merge: true));
    b.delete(d.collection('comments').doc(comment_id));

    return b.commit();
  }

  updateComment(
      {String text, String comment_id, String post_id, String group_id}) {
    return _fireStore
        .collection('groups')
        .doc(group_id)
        .collection('posts')
        .doc(post_id)
        .collection('comments')
        .doc(comment_id)
        .set({'text': text}, SetOptions(merge: true));
  }

  getComment({String comment_id, String post_id, String group_id}) {
    return _fireStore
        .collection('groups')
        .doc(group_id)
        .collection('posts')
        .doc(post_id)
        .collection('comments')
        .doc(comment_id)
        .get();
  }

  pinPost({String id_group, String id_post}) {
    return _fireStore
        .collection('groups')
        .doc(id_group)
        .collection('posts')
        .doc(id_post)
        .update(
      {'isPin': true},
    );
  }

  unPinPost({String id_group, String id_post}) {
    return _fireStore
        .collection('groups')
        .doc(id_group)
        .collection('posts')
        .doc(id_post)
        .update(
      {'isPin': FieldValue.delete()},
    );
  }
}
