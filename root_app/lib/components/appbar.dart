import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String titleText;

  CustomAppBar({this.height = kToolbarHeight, this.titleText = 'Default Title'});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo.png', // Replace with your logo image asset path
            width: 50,
            height: 50,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Add edit button functionality here
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
