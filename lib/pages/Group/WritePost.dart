import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';

class WritePostPage extends StatefulWidget {
  Group group;

  WritePostPage(this.group);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  TextEditingController _postTextController = TextEditingController();
  PostsController _postsController = PostsController();

  StorageController _storageController = StorageController();

  List<File> _images = [];

  bool waiting = false;

  Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            Languages.translate(
              context,
              'new_post',
            ),
          ),
          actions: [
            Tooltip(
              message: Languages.translate(
                context,
                'post',
              ),
              child: FlatButton(
                  onPressed: () {
                    if (waiting) {
                      return;
                    }
                    if (_postTextController.text.isEmpty &&
                        _images.length == 0) {
                      return;
                    } else {
                      _sendPost(_postTextController.text);
                    }
                  },
                  child: Icon(
                    waiting ? Icons.watch_later_outlined : Icons.post_add,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        body: ListView(
          children: [
            Container(
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                  hintText: Languages.translate(
                    context,
                    'write_post',
                  ),
                ),
                controller: _postTextController,
                maxLines: 17,
              ),
            ),
            Wrap(
              children: [
                for (File img in _images)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.file(
                        img,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _images.length == 0 ?
                TextButton.icon(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    final pickedFile = await _storageController.getImage();
                    if (pickedFile != null) {
                      {
                        setState(() {
                          _images.add(File(pickedFile.path));
                        });
                      }
                    }
                  },
                  label: Text(Languages.translate(
                    context,
                    'chose_image',
                  ),),
                ) :
                TextButton.icon(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    final pickedFile = await _storageController.getImage();
                    if (pickedFile != null) {
                      {
                        setState(() {
                          _images.clear();
                          _images.add(File(pickedFile.path));
                        });
                      }
                    }
                  },
                  label: Text("Change the image",),
                ),
              ],
            ),

            // RaisedButton(
            //   onPressed: () async {
            //     final pickedFile = await _storageController.getImage();
            //     if (pickedFile != null) {
            //       {
            //         setState(() {
            //           _images.add(File(pickedFile.path));
            //         });
            //       }
            //     }
            //   },
            //   color: Colors.indigo,
            //   child: Text(
            //     Languages.translate(
            //       context,
            //       'chose_image',
            //     ),
            //     style: TextStyle(
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
            // RaisedButton(
            //   onPressed: () {
            //     _sendPost(_postTextController.text);
            //   },
            //   color: Colors.indigo,
            //   child: !waiting?Text(
            //     Languages.translate(
            //       context,
            //       'post',
            //     ),
            //     style: TextStyle(
            //       color: Colors.white,
            //     ),
            //   ):Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       SizedBox(
            //           width: 18,
            //           height: 18,
            //           child: CircularProgressIndicator(backgroundColor: Colors.white,)),
            //       SizedBox(
            //         width: 12,
            //       ),
            //       Text(
            //         Languages.translate(
            //           context,
            //           'whaiting',
            //         ),
            //         style: TextStyle(
            //           fontSize: size.width / ConstValues.fontSize_2,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ));
  }

  void _sendPost(String text) async {
    setState(() {
      waiting = true;
    });
    await _postsController.createPost(text, _images, widget.group.id);
    Navigator.of(context).pop();
  }
}
