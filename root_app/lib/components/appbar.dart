// lib/components/appbar.dart
import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String titleText;

  CustomAppBar({this.height = kToolbarHeight, this.titleText = 'Default Title'});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor, // Use primary color
      title: Text(
        titleText,
        style: TextStyle(
          color: AppColors.textColor, // Use text color
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.accentColor), // Use accent color for the icon
          onPressed: () {
            // Add edit button functionality here
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
