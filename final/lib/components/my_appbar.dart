import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Main'),
      leading: IconButton(
        icon: Icon(Icons.person),
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.add,
            semanticLabel: 'add',
          ),
          onPressed: () => Navigator.pushNamed(context, '/item_add'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
