import 'package:flutter/material.dart';
import '../styles/colors.dart';

class CustomNavigationBar extends StatefulWidget {
  final PageController navController;
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({
    required this.navController,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 21,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              spreadRadius: 0,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.photo_library,
                    color: widget.currentIndex == 1
                        ? AppColors.iconColor
                        : Colors.grey,
                  ),
                  onPressed: () {
                    widget.onItemTapped(1);
                  },
                ),
                Text(
                  '전체',
                  style: TextStyle(
                    color: widget.currentIndex == 1
                        ? AppColors.iconColor
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.folder,
                    color: widget.currentIndex == 0
                        ? AppColors.iconColor
                        : Colors.grey,
                  ),
                  onPressed: () {
                    widget.onItemTapped(0);
                  },
                ),
                Text(
                  '폴더',
                  style: TextStyle(
                    color: widget.currentIndex == 0
                        ? AppColors.iconColor
                        : Colors.grey,
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
