import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stumeapp/Models/Comment.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/Sounds.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/ImageView/ImageView.dart';
import 'package:stumeapp/pages/widgets/FileWidget.dart';
import 'package:stumeapp/pages/widgets/UserPlaceholder.dart';
import 'package:stumeapp/pages/widgets/other.dart';

// import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CommentWidget.dart';

class PostWidget extends StatefulWidget {
  Post post;
  Group group;
  Function deletePost;
  Function updatePost;
  bool isHomePost;

  PostWidget({
    this.post,
    this.group,
    this.deletePost,
    this.updatePost,
    this.isHomePost = false,
  });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  bool commentsShow = false;
  List<DocumentSnapshot> comments = [];
  List<DocumentSnapshot> newComments = [];

  int commentsLimit = 5;
  bool hasMoreComments = true;
  bool isLoading = false;

  bool _isExbended = false;
  bool _isCommentExpended = false;

  MyEditController _commentController = MyEditController();

  PostsController _postsController = PostsController();
  AuthController _authController = AuthController();
  StorageController _storageController = StorageController();

  Size size;

  User user;

  Future _getUser;

  bool tag = true;

  // Sounds sounds = Sounds();

  Color buttonsColor;

  File image;
  File file;

  List _commentMentions = [];

  List menuItems;

  @override
  void dispose() {
    // sounds.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getUser = _authController.getUserInfo(widget.post.idOwner);
    _commentController.addListener(() {
      for (int i = 0; i < _commentMentions.length; i++) {
        if (_commentMentions[i]['start_at'] > _commentController.text.length) {
          _commentMentions.removeAt(i);
          i--;
        }
      }
    });

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    buttonsColor = Colors.grey[200];

    print("asdhgbalsjkbxas xiausk xhiasuk xiasu hxiasuj xhiuas xhasui");
    return _postBuilder(widget.post);
  }

  void _loadComments() async {
    if (!hasMoreComments) {
      print('No More Comments');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    _postsController
        .getComments(
      group: widget.group,
      postId: widget.post.id,
      last: comments.length == 0 ? null : comments.last,
      limit: commentsLimit,
    )
        .then((value) {
      setState(() {
        print('comments');
        comments.addAll(value.docs);
        isLoading = false;
        if (value.docs.length < commentsLimit) hasMoreComments = false;
      });
    });
  }

  Widget _postBuilder(Post post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            child: Column(
              children: [
                FutureBuilder(
                    future: _getUser,
                    builder: (context, snapshot) {
                      if (user != null) {
                        comments.insertAll(0, newComments);
                        newComments = [];
                        return _userWidget();
                      }
                      if (snapshot.hasData) {
                        try {
                          user = User().fromMap(snapshot.data)
                            ..setId(snapshot.data.id);
                          return _userWidget();
                        } catch (e) {
                          return UserPlaceholder();
                        }
                      }
                      return UserPlaceholder();
//                    return CircularProgressIndicator();
                    }),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                post.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: InkWell(
                          onLongPress: () {
                            Clipboard.setData(
                                    ClipboardData(text: widget.post.text))
                                .then((value) {
                              Fluttertoast.showToast(
                                msg:
                                    Languages.translate(context, 'text_copied'),
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: ConstValues.firstColor,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            });
                          },
                          child: ExpandableText(
                            post.text,
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 6,
                ),
                if (post.images != null && post.images.length > 0)
                  imagesBuilder(post.images),
                if (post.images != null && post.images.length > 0)
                  SizedBox(
                    height: 6,
                  ),
                if (post.files != null) docBuilder(post.files),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StreamBuilder(
                      stream: _postsController.isLikePost(
                          userId: _authController.getUser.uid,
                          group: widget.group,
                          postId: post.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.data() != null &&
                              snapshot.data.data()['exists'] == 1)
                            post.setIsLiked = true;
                          else
                            post.setIsLiked = false;
                        }
                        return RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          onPressed: () async {
                            setState(() {
                              if (!post.isLiked)
                                post.likeCount++;
                              else
                                post.likeCount--;
                            });
                            await _postsController.setLike(
                                userId: _authController.getUser.uid,
                                group: widget.group,
                                postId: post.id);

                            DocumentSnapshot d =
                                await _postsController.getPostChanges(
                              postId: post.id,
                              group: widget.group,
                            );
                            if (d.data() != null) {
                              widget.updatePost(d);

                              if (post.isLiked) {
                                // sounds.likeSound();
                              } else {
                                // sounds.disLikeSound();
                              }
                            }
                          },
                          color: post.getIsLiked
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : buttonsColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/like.svg',
                                  width: 20,
                                  height: 20,
                                  color: post.getIsLiked
                                      ? Colors.white
                                      : ConstValues.secondColor,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  post.likeCount.toString(),
                                  style: TextStyle(
                                    color: post.getIsLiked
                                        ? Colors.white
                                        : ConstValues.secondColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      onPressed: () {
                        setState(() {
                          commentsShow = !commentsShow;
                        });
                        _loadComments();
                      },
                      color: buttonsColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: ConstValues.secondColor,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              post.commentCount.toString(),
                              style: TextStyle(
                                color: ConstValues.secondColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: _postsController.isFollowPost(
                          userId: _authController.getUser.uid,
                          group: widget.group,
                          postId: post.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.data() != null &&
                              snapshot.data.data()['exists'] == 1)
                            post.setIsFollowed = true;
                          else
                            post.setIsFollowed = false;
                        }
                        return RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          onPressed: () async {
                            await _postsController.followPost(
                              userId: _authController.getUser.uid,
                              group: widget.group,
                              postId: post.id,
                            );

                            DocumentSnapshot d =
                                await _postsController.getPostChanges(
                              postId: post.id,
                              group: widget.group,
                            );
                            if (d.data() != null)
                              setState(() {
                                widget.post = Post().fromMap(d.data())
                                  ..setId(post.id);
                              });
                          },
                          color: post.getIsFollowed
                              ? Theme.of(context).primaryColor.withOpacity(0.7)
                              : buttonsColor.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.add_box,
                                  color: post.getIsFollowed
                                      ? Colors.white
                                      : ConstValues.secondColor,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  post.followCount.toString(),
                                  style: TextStyle(
                                    color: post.getIsFollowed
                                        ? Colors.white
                                        : ConstValues.secondColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (commentsShow && hasMoreComments)
                  FlatButton(
                    child: Text(Languages.translate(
                      context,
                      'load_more',
                    )),
                    onPressed: () {
                      _loadComments();
                    },
                  ),
                if (commentsShow)
                  for (int i = comments.length - 1; i >= 0; i--)
                    CommentWidget(
                        comment: Comment().fromMap(comments[i].data())
                          ..setId(comments[i].id),
                        post: widget.post,
                        group: widget.group,
                        doc: comments[i],
                        addPoint: (id) async {
                          var d = await _postsController.getPostChanges(
                            group: widget.group,
                            postId: post.id,
                          );
                          if (d.data() != null) widget.updatePost(d);
                        },
                        deletePoint: () async {
                          var d = await _postsController.getPostChanges(
                            group: widget.group,
                            postId: post.id,
                          );
                          if (d.data() != null) widget.updatePost(d);
                        },
                        deleteComment: (comment) async {
                          var d = await _postsController.getPostChanges(
                            group: widget.group,
                            postId: post.id,
                          );
                          if (d.data() != null) widget.updatePost(d);
                          comments.remove(comment);
                        },
                        updateComment: (comment) {
                          int index = comments.indexOf(comments[i]);
                          setState(() {
                            comments.removeAt(index);
                            comments.insert(index, comment);
                          });
                        }),
                if (commentsShow)
                  StreamBuilder(
                    stream: _postsController.getNewComments(
                      postId: post.id,
                      group: widget.group,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.docs.length > 0) {
                        print(
                            'nnnnnnnnneeeeeeeewwwwwwwwwwwwwwwwwwwwwww ccommmmmmmennttttttttt');
                        newComments = snapshot.data.docs;
                        return Row(
                          children: [
                            SizedBox(
                              width: size.width - 24,
                              child: Column(
                                children: [
                                  for (int i = 0; i < newComments.length; i++)
                                    CommentWidget(
                                        comment: Comment()
                                            .fromMap(newComments[i].data())
                                              ..setId(newComments[i].id),
                                        post: widget.post,
                                        group: widget.group,
                                        doc: newComments[i],
                                        addPoint: (id) async {
                                          var d = await _postsController
                                              .getPostChanges(
                                            group: widget.group,
                                            postId: post.id,
                                          );
                                          if (d.data() != null)
                                            widget.updatePost(d);
                                        },
                                        deletePoint: () async {
                                          var d = await _postsController
                                              .getPostChanges(
                                            group: widget.group,
                                            postId: post.id,
                                          );
                                          if (d.data() != null)
                                            widget.updatePost(d);
                                        },
                                        deleteComment: (comment) async {
                                          var d = await _postsController
                                              .getPostChanges(
                                            group: widget.group,
                                            postId: post.id,
                                          );
                                          if (d.data() != null)
                                            widget.updatePost(d);
                                          newComments.remove(comment);
                                        },
                                        updateComment: (comment) {
                                          int index = newComments
                                              .indexOf(newComments[i]);
                                          setState(() {
                                            newComments.removeAt(index);
                                            newComments.insert(index, comment);
                                          });
                                        }),
                                ],
                              ),
                            )
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                if (commentsShow) Divider(),
                if (commentsShow)
                  if (image != null)
                    Container(
                      margin:
                          EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 4),
                      width: 80,
                      height: 80,
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                // if (file != null)
                //   FileWidget(file.path)
                // else
                //   Container(
                //     height: 20,
                //     color: Colors.red,
                //   ),
                if (commentsShow)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(57),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Center(
                            child: Image.asset(ConstValues.userImage),
                          ),
                          imageUrl: MyUser.myUser.img,
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: Languages.translate(
                                context,
                                'write_comment',
                              )),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.alternate_email,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          User user = await Navigator.pushNamed(
                              context, '/SearchToTag',
                              arguments: {'groupId': widget.group.id}) as User;
                          setState(() {
                            _commentController.addMention({
                              'user': user,
                              'start_at': _commentController.text.length,
                              'end_at': _commentController.text.length +
                                  user.fullName.length +
                                  1,
                            });
                          });

                          _commentMentions.add({
                            'user_id': user.id,
                            'start_at': _commentController.text.length,
                            'end_at': user.fullName.length,
                          });
                        },
                      ),
                      //TODO -------------------
                      IconButton(
                        icon: Icon(
                          Icons.image,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          final pickedFile =
                              await _storageController.getImage();
                          if (pickedFile != null) {
                            {
                              setState(() {
                                image = File(pickedFile.path);
                              });
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          String text = _commentController.text;
                          if (text.isEmpty && image == null && file == null)
                            return;

                          if (!_authController.isBan()) {
                            print('send comment');
                            List ms = [];
                            for (Map m in _commentController.mentions)
                              ms.add({
                                'user_id': m['user'].id,
                                'start_at': m['start_at'],
                                'end_at': m['end_at'],
                              });
                            await _postsController.createComment(
                                text: text,
                                post: widget.post,
                                group: widget.group,
                                image: image,
                                file: file,
                                mentions: ms);
                            setState(() {
                              image = null;
                              file = null;
                              _commentMentions = [];
                              _commentController.clear();
                            });
                            // sounds.commentSound();
                          } else
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(Languages.translate(
                                      context,
                                      'blocked',
                                    )),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                          );
                                        },
                                        child: Text(
                                          Languages.translate(
                                            context,
                                            'ok',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _userWidget() {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/ProfilePage',
          arguments: {'id_user': widget.post.idOwner, 'user': user},
        );
      },
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: CachedNetworkImage(
          placeholder: (context, url) => Center(
            child: Image.asset(ConstValues.userImage),
          ),
          imageUrl: user.img != null ? user.img : ConstValues.userImage,
          fit: BoxFit.cover,
          width: 55,
          height: 55,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.firstName + ' ' + user.secondName,
          ),
          if (widget.post.isPin != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              decoration: BoxDecoration(
                color: ConstValues.firstColor[700],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                Languages.translate(
                  context,
                  'pinned_post',
                ),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          PopupMenuButton(
            // child: Icon(Icons.more_horiz),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: Icon(Icons.more_horiz, color: Colors.grey),

            itemBuilder: _buildMenu,
            onSelected: _handleMenuSelection,
          ),
          // SizedBox(
          //   height: 30,
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton<String>(
          //       isExpanded: false,
          //       value: null,
          //       icon: Icon(Icons.more_horiz),
          //       onChanged: (String newValue) {
          //         switch (newValue) {
          //           case 'Delete':
          //             _deletePost();
          //             break;
          //           case 'Edit':
          //             _editPost();
          //             break;
          //           case 'Report':
          //             _reportPost();
          //             break;
          //           case 'Block':
          //             _blockPost(widget.post.idOwner);
          //             break;
          //           case 'Pin':
          //             _pinPost();
          //             break;
          //           case 'Unpin':
          //             _unPinPost();
          //             break;
          //         }
          //       },
          //       items: menuItems,
          //     ),
          //   ),
          // ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.userTag != User.USER_TAG_NORMAL_USER
                ? Languages.translate(
                    context,
                    user.userTag,
                  )
                : Languages.translate(
                    context,
                    user.tag,
                  ),
            style: TextStyle(fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              widget.post.getStringDate,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  _deletePost() async {
    await _postsController.deletePost(
      groupId: widget.group.id,
      postId: widget.post.id,
    );
    widget.deletePost();
  }

  _reportPost() {
    Fluttertoast.showToast(
      msg: Languages.translate(context, 'report_done'),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: ConstValues.firstColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  _blockPost(String id_user) async {
    await _authController.blockUser(id_user: id_user);
  }

  _pinPost() {
    _postsController.pinPost(
        id_post: widget.post.id, id_group: widget.group.id);
  }

  _unPinPost() {
    _postsController.unPinPost(
        id_post: widget.post.id, id_group: widget.group.id);
  }

  _editPost() async {
    await Navigator.pushNamed(
      context,
      '/EditPostPage',
      arguments: {
        'post': widget.post,
        'group': widget.group,
        'editPost': (text) {}
      },
    );

    DocumentSnapshot d = await _postsController.getPostChanges(
      postId: widget.post.id,
      group: widget.group,
    );
    if (d.data() != null) widget.updatePost(d);
  }

  Widget imagesBuilder(List<dynamic> images) {
    List<Widget> dd = new List();

    for (String image in images) {
      dd.add(GestureDetector(
        onTap: () {
          print("------------------------");
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ImageView(image)));
        },
        child: Hero(
          tag: image,
          child: CachedNetworkImage(
            placeholder: (context, url) => Center(
              child: Container(
                width: size.width,
                height: size.width - 100,
                color: Colors.grey[200],
              ),
            ),
            imageUrl: image,
          ),
        ),
      ));
      dd.add(SizedBox(
        height: 2,
      ));
    }
    return Column(
      children: dd,
    );
  }

  Widget docBuilder(List files) {
    List<Widget> dd = new List();

    print(files);
    print(files.length);
    for (String file in files) {
      dd.add(Container(
        color: Colors.white24,
        child: FileWidget(file),
      ));
      dd.add(SizedBox(
        height: 4,
      ));
    }
    return Column(
      children: dd,
    );
  }

  List<PopupMenuItem> _buildMenu(context) {
    if (!widget.isHomePost)
      return [
        if (MyUser.myUser.id == widget.post.idOwner || MyUser.myUser.isAdmin())
          PopupMenuItem<String>(
            value: 'edit',
            child: Text(Languages.translate(context, 'edit')),
          ),
        if (MyUser.myUser.isAdmin())
          PopupMenuItem<String>(
            value: widget.post.isPin == null ? 'pin' : 'unpin',
            child: Text(Languages.translate(
              context,
              widget.post.isPin == null ? 'pin' : 'unpin',
            )),
          ),
        if (MyUser.myUser.id == widget.post.idOwner || MyUser.myUser.isAdmin())
          PopupMenuItem<String>(
            value: 'delete',
            child: Text(Languages.translate(
              context,
              'delete',
            )),
          ),
        if (MyUser.myUser.isAdmin())
          PopupMenuItem<String>(
            value: 'block',
            child: Text(Languages.translate(
              context,
              'block',
            )),
          ),
        if (MyUser.myUser.id != widget.post.idOwner)
          PopupMenuItem<String>(
            value: 'report',
            child: Text(Languages.translate(
              context,
              'report',
            )),
          ),
      ];
    else if (MyUser.myUser.isTheAdmin())
      return [
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(Languages.translate(
            context,
            'edit',
          )),
        ),
        PopupMenuItem<String>(
          value: widget.post.isPin == null ? 'pin' : 'unpin',
          child: Text(Languages.translate(
            context,
            widget.post.isPin == null ? 'pin' : 'unpin',
          )),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(Languages.translate(
            context,
            'delete',
          )),
        ),
        PopupMenuItem<String>(
          value: 'block',
          child: Text(Languages.translate(
            context,
            'block',
          )),
        ),
        PopupMenuItem<String>(
          value: 'report',
          child: Text(Languages.translate(
            context,
            'report',
          )),
        ),
      ];
  }

  void _handleMenuSelection(value) {
    switch (value) {
      case 'delete':
        _deletePost();
        break;
      case 'edit':
        _editPost();
        break;
      case 'report':
        _reportPost();
        break;
      case 'block':
        _blockPost(widget.post.idOwner);
        break;
      case 'pin':
        _pinPost();
        break;
      case 'unpin':
        _unPinPost();
        break;
    }
  }
}
