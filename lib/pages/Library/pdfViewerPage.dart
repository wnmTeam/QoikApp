import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PDFScreen extends StatefulWidget {
  String path;

  PDFScreen({this.path});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final controller = PdfViewerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: ValueListenableBuilder<Object>(
              // The controller is compatible with ValueListenable<Matrix4> and you can receive notifications on scrolling and zooming of the view.
              valueListenable: controller,
              builder: (context, _, child) => Text(controller.isReady
                  ? 'Page #${controller.currentPageNumber}'
                  : 'Page -')),
        ),
        backgroundColor: Colors.grey,
        body: FutureBuilder<File>(
            future: DefaultCacheManager().getSingleFile(widget.path),
            builder: (context, snapshot) {
              print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
              if (snapshot.hasData)
                return PdfViewer.openFile(
                  snapshot.data.path,
                  viewerController: controller,
                  onError: (err) => print(err),
                  params: PdfViewerParams(
                    padding: 10,
                    minScale: 1.0,
                  ),
                );
              else
                return Container();
            }),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.first_page),
              onPressed: () => controller.ready.goToPage(pageNumber: 1),
            ),
            FloatingActionButton(
              child: Icon(Icons.last_page),
              onPressed: () =>
                  controller.ready.goToPage(pageNumber: controller.pageCount),
            ),
          ],
        ),
      ),
    );
  }
}
