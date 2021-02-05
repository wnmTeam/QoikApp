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
  bool showAppBar = true;

  _ImageViewState(this.url);

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
            )
          : null,
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Colors.white,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularProgressIndicator(),
              LinearProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              )
            ],
          ),
        ),
        onTapUp: (context, details, controllerValue) {
          setState(() {
            showAppBar = !showAppBar;
          });
        },
      ),
    );
  }
}
