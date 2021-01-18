import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Models/Post.dart';
import 'package:stumeapp/controller/PostsController.dart';

class EditPostPage extends StatefulWidget {
  Post post;
  Group group;
  Function editPost;

  EditPostPage({this.post, this.group, this.editPost});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  TextEditingController _postTextController;

  PostsController _postsController = PostsController();

  @override
  void initState() {
    _postTextController = TextEditingController(text: widget.post.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Type Some Thing..',
                ),
                autofocus: true,
                controller: _postTextController,
                maxLines: 7,
              ),
            ),
            RaisedButton(
              onPressed: () async {
                await _postsController.updatePost(
                  id_group: widget.group.id,
                  id_post: widget.post.id,
                  text: _postTextController.text,
                );
                Navigator.pop(
                  context,
                  _postTextController.text,
                );
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
