import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package
import '../search_page.dart'; // Import search page

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({this.height = 80, Key? key})
      : super(key: key); // Increase the AppBar height

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height); // Set the preferred height
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isEditing = false; // Track toggle state

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), // Primary color
      leading: Row(
        children: [
          const SizedBox(
            width: 25,
            height: 15, // Invisible box with width of 50
          ),
          _buildLogo(),
        ],
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildLogo() {
    return Container(
      alignment: Alignment.centerLeft, // Align to the left without padding
      child: SvgPicture.asset('assets/logo.svg'),
    );
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        icon: Icon(Icons.search, color: AppColors.iconColor), // Search icon
        onPressed: () {
          // Navigate to the SearchPage when the search icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextButton(
          onPressed: _toggleEditing,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textColor,
            backgroundColor:
                isEditing ? AppColors.accentColor : Colors.transparent,
          ),
          child: Text(
            isEditing ? '추가' : '편집', // Toggle button text
            style: TextStyle(
              color: isEditing ? Colors.white : AppColors.iconColor,
            ),
          ),
        ),
      ),
    ];
  }
}
