import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/utils/icon_paths.dart';
import '../styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class FolderAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final bool isEditing;
  final VoidCallback onToggleEditing;

  const FolderAppBar({
    this.height = 56,
    Key? key,
    required this.isEditing,
    required this.onToggleEditing,
  }) : super(key: key);

  @override
  _FolderAppBarState createState() => _FolderAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height.h); // Responsive height
}

class _FolderAppBarState extends State<FolderAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              SvgPicture.asset(
                'assets/logo.svg',
                width: 72.w, // Responsive width
                height: 22.h, // Responsive height
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
      actions.addAll([
        IconButton(
          icon: SvgPicture.asset(
            IconPaths.getIcon('search'),
            width: 17.w, // Responsive width
            height: 17.h, // Responsive height
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ]);
    }

    // Edit button
    actions.add(
      GestureDetector(
        onTap: widget.onToggleEditing,
        child: Container(
          width: 55.w, // Responsive width
          height: 30.h, // Responsive height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r), // Responsive radius
            border: Border.all(
                color: const Color(0xFFE1E1E1),
                width: 1.2.w), // Responsive border width
          ),
          alignment: Alignment.center,
          child: Text(
            widget.isEditing ? '완료' : '편집',
            style: TextStyle(
              color: const Color(0xFF00376E),
              fontSize: 12.sp, // Responsive font size
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w300,
              letterSpacing: 0.1.sp, // Responsive letter spacing
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // MY button (hidden when editing)
    if (!widget.isEditing) {
      actions.add(SizedBox(width: 4.w)); // Responsive spacing
      actions.add(IconButton(
        icon: SvgPicture.asset(
          IconPaths.getIcon('my'),
          width: 25.w, // Responsive width
          height: 13.h, // Responsive height
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/my');
        },
      ));
    }

    return actions;
  }
}
