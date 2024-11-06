import 'package:flutter/material.dart';
import '../colors.dart'; // Import the app-specific color constants
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG images

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final bool isEditing;
  final VoidCallback onToggleEditing;

  const MainAppBar({
    this.height = 56,
    Key? key,
    required this.isEditing,
    required this.onToggleEditing,
  }) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              SvgPicture.asset(
                'assets/logo.svg',
                width: 30,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Row(
            children: _buildActions(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      // Bubble Text Placeholder for Search
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          '콘텐츠 제목을 검색해보세요!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ),
      const SizedBox(width: 4), // Space between search icon and actions

      // Search button
      IconButton(
        icon: const Icon(Icons.search, color: AppColors.iconColor),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),

      // Add/Edit button
      TextButton(
        onPressed: widget.onToggleEditing, // Call the toggle callback
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textColor,
          backgroundColor: widget.isEditing
              ? AppColors.accentColor
              : const Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          widget.isEditing ? '완료' : '편집',
          style: TextStyle(
            color: widget.isEditing ? Colors.white : AppColors.iconColor,
          ),
        ),
      ),
    ];
  }
}
