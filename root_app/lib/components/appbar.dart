// lib/components/appbar.dart
import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  CustomAppBar({this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor, // Use primary color
      leading: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.asset(
          'assets/logo.png', // Path to your logo image
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppColors.iconColor), // Search icon
          onPressed: () {
            // Add search button functionality here
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.iconColor), // Edit icon
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
