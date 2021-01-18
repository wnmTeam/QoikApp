import 'package:flutter/material.dart';

class UserPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(57),
          child: Container(
            color: Colors.grey[200],
            width: 57,
            height: 57,
          )),
      title: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child: Container(
                color: Colors.grey[200],
                width: 150,
                height: 20,
              )),
        ],
      ),
      subtitle: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(57),
              child: Container(
                color: Colors.grey[200],
                width: 70,
                height: 10,
              )),
        ],
      ),
    );
  }
}

