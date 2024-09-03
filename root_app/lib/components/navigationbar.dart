// lib/components/navigationbar.dart
import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  bool isAllSelected = false;
  bool isFolderSelected = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.buttonColor, // Use button color
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonShadowColor, // Use shadow color
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: isAllSelected ? AppColors.iconColor : Colors.grey, // Use icon color or grey
                  ),
                  onPressed: () {
                    setState(() {
                      isAllSelected = true;
                      isFolderSelected = false;
                    });
                  },
                ),
                Text(
                  'All',
                  style: TextStyle(
                    color: isAllSelected ? AppColors.iconColor : Colors.grey, // Use icon color or grey
                  ),
                ),
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.folder,
                    color: isFolderSelected ? AppColors.iconColor : Colors.grey, // Use icon color or grey
                  ),
                  onPressed: () {
                    setState(() {
                      isFolderSelected = true;
                      isAllSelected = false;
                    });
                  },
                ),
                Text(
                  'Folder',
                  style: TextStyle(
                    color: isFolderSelected ? AppColors.iconColor : Colors.grey, // Use icon color or grey
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
