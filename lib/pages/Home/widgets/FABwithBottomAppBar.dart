import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:badges/badges.dart';


class FABBottomAppBarItem {
  FABBottomAppBarItem({this.iconData, this.text, this.svgIcon, this.stream});

  IconData iconData;
  String text;
  String svgIcon;

  Stream stream;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height: 60.0,
    this.iconSize: 24.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
    this.loading
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }

  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  bool loading;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 1;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText ?? '',
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    FABBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    Color color =
        _selectedIndex == index ? widget.selectedColor : Colors.white60;
    return StreamBuilder(
        stream: !widget.loading
            ? item.stream
            : null,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.data() != null) {
            // TODO add sound here
            return Expanded(
              child: Badge(
                showBadge: snapshot.data['count'] != 0,
                badgeColor: Theme.of(context).accentColor,
                badgeContent: Text(
                  snapshot.data['count'].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6,
                  ),
                ),
                position: BadgePosition.topEnd(top: 8, end: 20),
                child: SizedBox(
                  height: widget.height,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => onPressed(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          item.svgIcon == null
                              ? Icon(item.iconData, color: color, size: widget.iconSize)
                              : SvgPicture.asset(
                            'assets/lib.svg',
                            color: color,
                            width: 22,
                            height: 22,
                          ),
                          Text(
                            item.text,
                            maxLines: 1,
                            style: TextStyle(color: color),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Expanded(
            child: SizedBox(
              height: widget.height,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onPressed(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      item.svgIcon == null
                          ? Icon(item.iconData, color: color, size: widget.iconSize)
                          : SvgPicture.asset(
                        'assets/lib.svg',
                        color: color,
                        width: 22,
                        height: 22,
                      ),
                      Text(
                        item.text,
                        maxLines: 1,
                        style: TextStyle(color: color),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
