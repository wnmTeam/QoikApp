import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/Models/LibrarySection.dart';
import 'package:stumeapp/Models/MyUser.dart';
import 'package:stumeapp/api/library_api.dart';
import 'package:stumeapp/const_values.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/StorageController.dart';
import 'package:firebase_storage/firebase_storage.dart' as str;
// import 'package:path/path.dart';

import '../../localization.dart';

class UploadBookPage extends StatefulWidget {
  @override
  _UploadBookPageState createState() => _UploadBookPageState();
}

class _UploadBookPageState extends State<UploadBookPage> {
  AuthController _authController = AuthController();
  LibraryApi _libraryController = LibraryApi();
  StorageController _storageController = StorageController();

  String _librarySection;
  TextEditingController _lessonTitleController = TextEditingController();
  String _university;
  String _college;
  String _subject_name;
  String _lesson_title;

  bool _uploadDone = false;

  double _uploadValue = 0;

  File file;

  Map _librarySections = {};

  int _currentStep = 0;
  StepperType stepperType = StepperType.vertical;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Languages.translate(
          context,
          'upload_book',
        )),
      ),
      body: Stepper(
        type: stepperType,
        physics: ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) => tapped(step),
        onStepContinue: continued,
        onStepCancel: cancel,
        steps: <Step>[
          Step(
            title: new Text(Languages.translate(
              context,
              'chose_library_section',
            )),
            content: ListTile(
              onTap: () {
                _bottomSheetBuild(
                  'librarySections',
                  _libraryController.getCategories(),
                );
              },
              contentPadding: EdgeInsets.zero,
              title: Text(Languages.translate(
                context,
                'chose_library_section',
              )),
              subtitle: Text(_librarySection == null
                  ? Languages.translate(
                      context,
                      'tap_to_select',
                    )
                  : Languages.translate(
                      context,
                      _librarySection,
                    )),
              leading: Icon(CupertinoIcons.book),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: new Text(Languages.translate(
              context,
              'book_info',
            )),
            content: Column(
              children: [
                TextFormField(
                  controller: _lessonTitleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: Languages.translate(
                      context,
                      'lesson_title',
                    ),
                    icon: Icon(CupertinoIcons.bookmark),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                  onTap: () {
                    _bottomSheetBuild(
                      'subjects',
                      null,
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(Languages.translate(
                    context,
                    'subject_name',
                  )),
                  subtitle: Text(_subject_name == null
                      ? Languages.translate(
                          context,
                          'tap_to_select',
                        )
                      : _subject_name),
                  leading: Icon(CupertinoIcons.bookmark),
                ),
                SizedBox(
                  height: 20,
                ),

                _universityCollegeBuilder(),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: new Text(Languages.translate(
              context,
              'chose_book',
            )),
            content: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  file != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.doc_fill,
                                    color: ConstValues.firstColor[700],
                                    size: 70,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    file.path.split('/').last,
                                    style: TextStyle(fontSize: 21),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await _storageController.getDoc();
                      if (pickedFile != null) {
                        print("${pickedFile.path}\n");
                        setState(() {
                          file = pickedFile;
                        });
                      } else {
                        print("no file selected");
                      }
                    },
                    child: Text(Languages.translate(
                      context,
                      'chose_book',
                    )),
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
            state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
          ),
          Step(
            title: new Text(Languages.translate(
              context,
              'upload_book',
            )),
            content: Center(
              child: Container(
                margin: EdgeInsets.all(10),
                height: 150,
                width: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadValue,
                      strokeWidth: 15,
                      backgroundColor: ConstValues.firstColor,
                    ),
                    Center(
                        child: Text(
                            (_uploadValue * 100).toInt().toString() + " %")),
                  ],
                ),
              ),
            ),
            isActive: _currentStep >= 3,
            state: _currentStep >= 3 || _uploadDone
                ? StepState.complete
                : StepState.disabled,
          ),
        ],
      ),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  bool canContinue() {
    switch (_currentStep) {
      case 0:
        if (_librarySection == null) {
          return false;
        }
        _subject_name = null;
        _lesson_title = null;
        return true;
      case 1:
        if (
            _lessonTitleController.text.trim().isEmpty ||
            _subject_name == null ||
            _university == null ||
            _college == null) {
          return false;
        }
        return true;
      case 2:
        if (file == null) {
          return false;
        }
        return true;
      case 3:
        return false;
    }
  }

  continued() {
    if (!canContinue()) return;
    setState(() {
      _currentStep += 1;
    });
    if (_currentStep == 3) {
      _uploadBook();
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  _universityCollegeBuilder() {
    return Column(
      children: [
        ListTile(
          onTap: () {
            _bottomSheetBuild(
              'universities',
              _authController.getUniversities(),
            );
          },
          contentPadding: EdgeInsets.zero,
          title: Text(Languages.translate(
            context,
            'university',
          )),
          subtitle: Text(_university == null
              ? Languages.translate(
                  context,
                  'tap_to_select',
                )
              : _university),
          leading: Icon(Icons.account_balance_outlined),
        ),
        SizedBox(
          height: 20,
        ),
        ListTile(
          onTap: () {
            _bottomSheetBuild(
              'colleges',
              _authController.getColleges(),
            );
          },
          contentPadding: EdgeInsets.zero,
          title: Text(Languages.translate(
            context,
            'college',
          )),
          subtitle: Text(_college == null
              ? Languages.translate(
                  context,
                  'tap_to_select',
                )
              : _college),
          leading: Icon(Icons.account_balance_outlined),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _bottomSheetBuild(
    String type,
    Future future,
  ) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
//        isScrollControlled: true,
        builder: (BuildContext context) {
          String temp;
          temp = type;
          return future != null
              ? FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List list = [];
                      if (temp == 'librarySections') {
                        print(snapshot.data.docs.length);
                        for (var d in snapshot.data.docs) {
                          list.add(d.id);
                          _librarySections[d.id] =
                              LibrarySection().fromMap(d.data())..setId(d.id);
                        }
                        print(_librarySections);
                      } else if (temp == 'subjects') {
                        list = _librarySections[_librarySection].subjects;
                      } else {
                        print(snapshot.data.data());

                        list = snapshot.data.data()[temp];
                      }
                      list.sort();
                      print(list);
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          String item = list[index];
                          return null != item
                              ? ListTile(
                                  title: Text(type != 'librarySections'
                                      ? item
                                      : Languages.translate(
                                          context,
                                          item,
                                        )),
                                  onTap: () {
                                    setState(() {
                                      if (type == 'colleges')
                                        _college = item;
                                      else if (type == 'subjects') {
                                        if (null == item) _addSubject();
                                        _subject_name = item;
                                      } else if (type == 'librarySections')
                                        _librarySection = item;
                                      else
                                        _university = item;
                                    });
                                    Navigator.pop(context, item);
                                  },
                                )
                              : ListTile(
                                  leading: Icon(
                                    Icons.add_circle,
                                    color: ConstValues.firstColor,
                                  ),
                                  onTap: () {},
                                );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
              : ListView.builder(
                  itemCount: _librarySections[_librarySection].subjects.length,
                  itemBuilder: (context, index) {
                    String item =
                        _librarySections[_librarySection].subjects[index];
                    return null != item
                        ? ListTile(
                            title: Text(item),
                            onTap: () {
                              setState(() {
                                if (type == 'colleges')
                                  _college = item;
                                else if (type == 'subjects')
                                  _subject_name = item;
                                else if (type == 'librarySections')
                                  _librarySection = item;
                                else
                                  _university = item;
                              });
                              Navigator.pop(context, item);
                            },
                          )
                        : ListTile(
                            leading: Icon(
                              Icons.add_circle,
                              color: ConstValues.firstColor,
                            ),
                            title: Text(Languages.translate(
                              context,
                              '_add_subject',
                            )),
                            onTap: () {
                              _addSubject();
                            },
                          );
                  },
                );
        });
  }

  void _uploadBook() async {
    print('START UPLOADING BOOK');
    Book book = Book(
      publisher: MyUser.myUser.id,
      section: _librarySection,
      university: _university,
      college: _college,
      is_pending: true,
      subject_name: _subject_name,
      lesson_title: _lessonTitleController.text,
    )..setId();
    String url = await _storageController.uploadBook(book, file,
        (str.TaskSnapshot event) {
      print(_uploadValue);
      setState(() {
        _uploadValue =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });
    });

    await _libraryController.createBookRecord(book: book);
    Navigator.pop(context);
  }

  void _addSubject() {
    TextEditingController _subjectController = TextEditingController();
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
//        isScrollControlled: true,
        builder: (BuildContext context) {
          return Column(
            children: [
              TextFormField(
                controller: _subjectController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(Languages.translate(
                        context,
                        'cancel',
                      ))),
                  ElevatedButton(
                    onPressed: () async {
                      if (_subjectController.text.trim().isEmpty) return;
                      await _libraryController.addSubject(
                        subject: _subjectController.text.trim(),
                        section: _librarySection,
                      );
                      setState(() {
                        _subject_name = _subjectController.text.trim();
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(Languages.translate(context, '_add')),
                  ),
                ],
              )
            ],
          );
        });
  }
}
