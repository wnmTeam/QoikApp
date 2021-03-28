import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Group.dart';
import 'package:stumeapp/Sounds.dart';
import 'package:stumeapp/controller/PostsController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:stumeapp/localization.dart';
import 'package:stumeapp/pages/widgets/FileWidget.dart';

class WritePostPage extends StatefulWidget {
  final Group group;

  WritePostPage(this.group);

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  TextEditingController _postTextController = TextEditingController();
  PostsController _postsController = PostsController();

  StorageController _storageController = StorageController();

  List<File> _images = [];
  List<File> _files = [];

  bool waiting = false;

  Size size;
  // Sounds sounds = Sounds();
  bool multiImages = true;

  @override
  void dispose() {
    // sounds.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;

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
                      _images.length == 0 &&
                      _files.length == 0) {
                    return;
                  } else {
                    _sendPost(_postTextController.text);
                  }
                },
                  child: waiting ? Icon(
                    Icons.watch_later_outlined,
                    color: Colors.white,
                  ) : Icon(
                    Icons.post_add,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
        body: ListView(
          children: [
            Container(
              color: Colors.white10,
            child: TextField(
              enableSuggestions: true,
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
                  Container(
                    margin: EdgeInsets.only(left: 4, right: 4, bottom: 4, top:
                    4),
                    width: 150,
                    height: 150,
                    child: Image.file(
                      img,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),

            Column(
              children: [
                for (File file in _files)
                  FileWidget(file.path)
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
                      label: Text(
                        Languages.translate(
                          context,
                          'chose_image',
                        ),
                      ),
                    )
                  : TextButton.icon(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () async {
                        final pickedFile = await _storageController.getImage();
                        if (pickedFile != null) {
                          {
                            setState(() {
                              if (!multiImages) {
                                _images.clear();
                              }
                              _images.add(File(pickedFile.path));
                            });
                          }
                        }
                      },
                  label: Text(
                    multiImages
                        ? Languages.translate(context, "add_image")
                        : Languages.translate(context, "change_image"),
                  ),
                ),

                //Send Files
                TextButton.icon(
                  icon: Icon(Icons.insert_drive_file_rounded),
                  onPressed: () async {
                    final pickedFile = await _storageController.getDocs();
                    if (pickedFile != null) {
                      for (File file in pickedFile) {
                        print("${file.path}\n");
                        _files.add(file);
                      }
                      setState(() {

                      });
                    }
                  },
                  label: Text(Languages.translate(context, "add_file")),
                ),

                // TextButton.icon(
                //   icon: Icon(Icons.camera_alt),
                //
                //   onPressed: () async {
                //     final pickedFile = await _storageController.getImage();
                //     if (pickedFile != null) {
                //       {
                //         setState(() {
                //           _images.add(File(pickedFile.path));
                //         });
                //       }
                //       }
                //     },
                //     label: Text(
                //       Languages.translate(
                //         context,
                //         'chose_image',
                //       ),
                //
                //     ),
                //   ),
                //   TextButton.icon(
                //     icon: Icon(Icons.post_add),
                //     onPressed: () {
                //       if (_postTextController.text.isEmpty && _images.length == 0) {
                //         return;
                //       } else {
                //         _sendPost(_postTextController.text);
                //       }
                //     },
                //     label: !waiting
                //         ? Text(
                //             Languages.translate(
                //               context,
                //               'post',
                //             ),
                //           )
                //         : Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               SizedBox(
                //                   width: 18,
                //                   height: 18,
                //                   child: CircularProgressIndicator(
                //                     backgroundColor: Colors.white,
                //                   )),
                //               SizedBox(
                //                 width: 12,
                //               ),
                //               Text(
                //                 Languages.translate(
                //                   context,
                //                   'whaiting',
                //                 ),
                //                 style: TextStyle(
                //                   fontSize: size.width / ConstValues.fontSize_2,
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ],
                //           ),
                //   ),
              ],
          ),
        ],
      ),
    );
  }

  void _sendPost(String text) async {
    setState(() {
      waiting = true;
    });
    await _postsController.createPost(text, _images, _files, widget.group.id);
    // sounds.postSound();
    Navigator.of(context).pop();
  }


}
