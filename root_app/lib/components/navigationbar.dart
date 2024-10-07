import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  bool isAllSelected = true; // Set to true so "All" is selected by default
  bool isFolderSelected = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 21,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Container(
        width: double.infinity, // Equivalent to width: 100% in CSS
        height: 100, // Set the height, adjust as needed
        decoration: BoxDecoration(
          color:
              Colors.white, // Background color equivalent to background: white
          borderRadius: BorderRadius.circular(30.0), // Border radius: 30px
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.10), // Shadow color (0, 0, 0, 0.10)
              spreadRadius: 0, // Spread radius set to 0
              blurRadius: 5, // Blur radius equivalent to blur-radius: 5px
              offset: Offset(0, 1), // Offset equivalent to 0px 1px in CSS
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the icon and text
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: isAllSelected
                        ? AppColors.iconColor
                        : Colors.grey, // Use icon color or grey
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
                    color: isAllSelected
                        ? AppColors.iconColor
                        : Colors.grey, // Use icon color or grey
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the icon and text
              children: [
                IconButton(
                  icon: Icon(
                    Icons.folder,
                    color: isFolderSelected
                        ? AppColors.iconColor
                        : Colors.grey, // Use icon color or grey
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
                    color: isFolderSelected
                        ? AppColors.iconColor
                        : Colors.grey, // Use icon color or grey
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
