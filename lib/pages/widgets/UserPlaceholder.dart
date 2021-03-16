import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stumeapp/main.dart';

class UserPlaceholder extends StatelessWidget {
  final Color baseColor = MyAppState.isDark ? Colors.black87 : Colors.grey[100];
  final Color highlightColor =
      MyAppState.isDark ? Colors.black54 : Colors.grey[300];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(57),
            child: Container(
              color: Colors.grey,
              width: 57,
              height: 57,
            )),
      ),
      title: Row(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: Container(
                  color: Colors.grey,
                  width: 150,
                  height: 20,
                )),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: Container(
                  color: Colors.grey,
                  width: 70,
                  height: 10,
                )),
          )
        ],
      ),
    );
  }
}

