import 'package:flutter/material.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
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
                    color: isAllSelected ? Colors.blue : Colors.grey,
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
                    color: isAllSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.folder,
                    color: isFolderSelected ? Colors.blue : Colors.grey,
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
                    color: isFolderSelected ? Colors.blue : Colors.grey,
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
