import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:stumeapp/controller/LibraryController.dart';

class BookViewerPage extends StatefulWidget {
  String id;


  BookViewerPage({this.id});

  @override
  _BookViewerPageState createState() => _BookViewerPageState();
}

class _BookViewerPageState extends State<BookViewerPage> {
  bool _isLoading = true;
  PDFDocument document;
  String url;

  LibraryController _libraryController = LibraryController();

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    url = await _libraryController.getDownloadLink(
      id: widget.id,
    );
    document = await PDFDocument.fromURL(url);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.id),
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
          document: document,
        ),
      ),
    );
  }
}