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
    return Container(
      child: Hero(
        tag: "chat_image",
        child: PhotoView(
          imageProvider: NetworkImage(url),
          enableRotation: true,
          loadFailedChild: Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: width / 2,
            ),
          ),
        ),
      ),
      color: Colors.white,
    );
  }
}
