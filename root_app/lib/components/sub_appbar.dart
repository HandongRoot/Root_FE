import 'package:flutter/material.dart';
import '../colors.dart'; // Import the app-specific color constants
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG images

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const SubAppBar({this.height = 90, Key? key}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Remove shadow for a cleaner look
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Logo section
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16), // Left padding
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 30,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Space between logo and search bar
          // Search bar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2), // Light gray background color
                borderRadius: BorderRadius.circular(16), // Rounded edges
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.blue, // Icon color as in the image
                  ),
                  const SizedBox(width: 8), // Space between icon and text
                  const Text(
                    '찾으시는 콘텐츠 제목을 입력하세요',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14, // Font size for placeholder text
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
