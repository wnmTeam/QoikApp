import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stumeapp/Models/Book.dart';
import 'package:stumeapp/Models/LibrarySection.dart';
import 'package:stumeapp/Models/User.dart';
import 'package:stumeapp/controller/AuthController.dart';
import 'package:stumeapp/controller/LibraryController.dart';
import 'package:stumeapp/localization.dart';
import 'package:url_launcher/url_launcher.dart';

class BooksPage extends StatefulWidget {
  final LibrarySection section;

  BooksPage({this.section}) {
    this.section.subjects.removeLast();
  }

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 50;
  DocumentSnapshot lastDocument = null;

  AuthController _authController = AuthController();
  LibraryController _libraryController = LibraryController();

  List<DocumentSnapshot> books = [];
  List<DocumentSnapshot> searchBooks = [];
  bool isSearch = false;
  TextEditingController _searchController = TextEditingController();
  int bookCount;
  bool openSearchBar = false;

  Book filterBook = Book();

  @override
  void initState() {
    getMyBooks();
    super.initState();
  }

  // FocusNode focusNode  = FocusNode ();
  @override
  Widget build(BuildContext context) {
    bookCount = isSearch ? searchBooks.length : books.length;
    return WillPopScope(
      onWillPop: _pop,
      child: Scaffold(
        appBar: AppBar(
          title: openSearchBar
              ? TextField(
                  // focusNode: focusNode,
                  autofocus: true,
                  controller: _searchController,
                  decoration: InputDecoration(
                      // fillColor: Colors.white,

                      border: InputBorder.none,
                      hintText: Languages.translate(
                        context,
                        'search',
                      ),
                      hintStyle: TextStyle(color: Colors.white70)),
                  onChanged: (value) {
                      _search(value.trim());

                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _search(value.trim());
                    }
                  },
                  style: TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.search,
                )
              : Text(widget.section.id),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () {
                setState(() {
                  for(var b in books)
                    searchBooks.add(b);

                  openSearchBar = true;
                  isSearch = true;
                });
              },
            ),
            SizedBox(
              width: 10,
              height: 20,
            ),
          ],
        ),
        body: bookCount == 0
            ? Center(
                child: Text(Languages.translate(context, "empty")),
              )
            : Column(
                children: [
                  isSearch
                      ? Wrap(
                          spacing: 5,
                          children: [
                            RaisedButton(
                              // elevation: 0,
                              onPressed: () async {
                                String item = await _bottomSheetBuild(
                                  'universities',
                                  _authController.getUniversities(),
                                );
                                setState(() {
                                  filterBook.university = item;
                                });
                              },
                              child: Text(
                                filterBook.university != null
                                    ? filterBook.university
                                    : Languages.translate(
                                        context,
                                        'university',
                                      ),
                                style: TextStyle(fontSize: 13),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            RaisedButton(
                              // elevation: 0,
                              onPressed: () async {
                                String item = await _bottomSheetBuild(
                                  'colleges',
                                  _authController.getColleges(),
                                );
                                setState(() {
                                  filterBook.college = item;
                                });
                              },
                              child: Text(
                                filterBook.college != null
                                    ? filterBook.college
                                    : Languages.translate(
                                        context,
                                        'college',
                                      ),
                                style: TextStyle(fontSize: 13),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            RaisedButton(
                              // elevation: 0,
                              onPressed: () async {
                                String item = await _bottomSheetBuild(
                                  'subjects',
                                  null,
                                );
                                setState(() {
                                  filterBook.subject_name = item;
                                });
                              },
                              child: Text(
                                filterBook.subject_name != null
                                    ? filterBook.subject_name
                                    : '_subjectName',
                                style: TextStyle(fontSize: 13),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            RaisedButton.icon(
                              icon: Icon(
                                Icons.clear,
                                size: 17,
                                color: Colors.white,
                              ),
                              label: Text(
                                  Languages.translate(
                                    context,
                                    'clear',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                              elevation: 0,
                              onPressed: () {
                                setState(() {
                                  filterBook = Book();
                                  _search(_searchController.text.trim());
                                });
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  Expanded(
                    child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 0.8,
                        children: List.generate(
                            isSearch ? searchBooks.length : books.length,
                            (index) {
                          return BookWidget(
                              book: Book().fromMap(isSearch
                                  ? searchBooks[index].data()
                                  : books[index].data())
                                ..setId(isSearch
                                    ? searchBooks[index].id
                                    : books[index].id));
                        })),
                  ),
                ],
              ),
      ),
    );
  }

  void _search(String value) {
    searchBooks.clear();
    for (int i = 0; i < books.length; i++) {
      Book book = Book().fromMap(books[i].data());
      if (book.name.contains(value) && _applyFilter(book)) {
        searchBooks.add(books[i]);
      }
    }
    setState(() {
      lastDocument = null;
      hasMore = true;
      isSearch = true;
    });
  }

  getMyBooks() async {
    if (!hasMore) {
      print('No More books');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
//      posts.add(null);
    });
    _libraryController
        .getBooks(
      section: widget.section.id,
      limit: documentLimit,
      last: lastDocument,
    )
        .then((value) {
      print('books');
      print(value.docs.length);
      setState(() {
        books.addAll(value.docs);
        isLoading = false;
        try {
          lastDocument = books.last;
        } catch (e) {}
      });
    });
  }

  bool _applyFilter(Book book) {
    if (filterBook.university != null &&
        book.university != filterBook.university) return false;
    if (filterBook.college != null && book.college != filterBook.college)
      return false;
    if (filterBook.subject_name != null &&
        book.subject_name != filterBook.subject_name) return false;
    return true;
  }

  Future<bool> _pop() async {
    if (isSearch == true) {
      setState(() {
        isSearch = false;
        openSearchBar = false;
      });
      return false;
    }
    return true;
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
                      if (temp == 'subjects') {
                        list = widget.section.subjects;
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
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              setState(() {
                                if (type == 'colleges')
                                  filterBook.college = item;
                                else if (type == 'subjects') {
                                  filterBook.subject_name = item;
                                } else
                                  filterBook.university = item;
                              });
                              _search(_searchController.text.trim());
                              Navigator.pop(context, item);
                            },
                          );
                        },
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
              : ListView.builder(
                  itemCount: widget.section.subjects.length,
                  itemBuilder: (context, index) {
                    String item = widget.section.subjects[index];
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          if (type == 'subjects')
                            filterBook.subject_name = item;
                        });
                        _search(_searchController.text.trim());
                        Navigator.pop(context, item);
                      },
                    );
                  },
                );
        });
  }
}

class BookWidget extends StatefulWidget {
  final Book book;

  BookWidget({this.book});

  @override
  _BookWidgetState createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> {
  AuthController _authController = AuthController();

  LibraryController _libraryController = LibraryController();

  User user;

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () async {
        Navigator.of(context).pushNamed('/BookInfoPage', arguments: {
          'book': widget.book,
        });
      },
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ),
              ),
            ),
          ),
          Text(widget.book.name),
        ],
      ),
    );
  }
}
