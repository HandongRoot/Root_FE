import 'package:flutter/material.dart';
import '../styles/colors.dart'; // Import the app-specific color constants
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
      // 내릴때 색 변하는거 방지
      elevation: 0,
      surfaceTintColor: Colors.transparent,
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
    List<Widget> actions = [];

    if (!widget.isEditing) {
      // Show search bar and icon only when not in edit mode
      actions.addAll([
        const SizedBox(width: 4), // Space between search and MY button
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.iconColor),
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ]);
    }

    // Add edit button
    actions.add(
      TextButton(
        onPressed: widget.onToggleEditing,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textColor,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          widget.isEditing ? '완료' : '편집', // Toggle text based on edit mode
          style: const TextStyle(
            color: AppColors.iconColor, // Keep color consistent
          ),
        ),
      ),
    );
    // Add "MY" button
    actions.add(
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/my');
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.iconColor,
          backgroundColor: Colors.transparent,
        ),
        child: const Text(
          'MY',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );

    return actions;
  }
}
