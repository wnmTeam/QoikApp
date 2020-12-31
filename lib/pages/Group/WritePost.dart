import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/PostsController.dart';

class WritePostPage extends StatefulWidget {
  Group group;

  WritePostPage(this.group);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  TextEditingController _postTextController = TextEditingController();
  PostsController _postsController = PostsController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('New Post'),
        ),
        body: ListView(
          children: [
            Container(
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: 'Type Some Thing..',
                ),
                controller: _postTextController,
                maxLines: 7,
              ),
            ),
            RaisedButton(
              onPressed: () {
                _sendPost(_postTextController.text);
              },
              color: Colors.indigo,
              child: Text(
                'submet',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }

  void _sendPost(String text) async {
    await _postsController.createPost(text, widget.group.id);
    Navigator.of(context).pop();
  }
}
