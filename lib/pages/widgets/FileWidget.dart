import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileWidget extends StatelessWidget {
  final String file;

  FileWidget(this.file);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        file.split('/').last,
        maxLines: 3,
      ),
      leading: Icon(
        Icons.insert_drive_file_rounded,
      ),
      // leading: Image.network(file),
      trailing: IconButton(
        icon: Icon(
          Icons.file_download,
        ),
        onPressed: () async {
          //TODO search for download package
          if (file != null) {
            await launch(file).then((value) => print('path  ' + file));
          } else {
            throw 'cant launch url';
          }
        },
      ),
    );
  }
}
