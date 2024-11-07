import 'package:flutter/material.dart';
import '../styles/colors.dart'; // Import the app-specific color constants
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG images

class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const SubAppBar({
    this.height = 56,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: 30,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
          // Actions with only the search icon
          Row(
            children: _buildActions(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      const SizedBox(width: 4), // Spacing before the search icon
      IconButton(
        icon: const Icon(Icons.search, color: AppColors.iconColor),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
