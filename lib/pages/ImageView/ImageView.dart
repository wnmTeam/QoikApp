import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  String url;

  ImageView(this.url);

  @override
  _ImageViewState createState() => _ImageViewState(url);
}

class _ImageViewState extends State<ImageView> {
  String url;
  double width;

  _ImageViewState(this.url);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
          enableRotation: true,
          heroAttributes: PhotoViewHeroAttributes(tag: url),
          minScale: PhotoViewComputedScale.contained,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: width / 2,
            ),
          ),
          loadFailedChild: Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: width / 2,
            ),
          ),
          loadingBuilder: (context, event) => Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 200,
                ),
                LinearProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                )
              ],
            ),
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}