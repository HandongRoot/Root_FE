import 'package:flutter/material.dart';
import 'package:root_app/utils/icon_paths.dart';
import '../styles/colors.dart';

import 'package:flutter_svg/flutter_svg.dart';

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
    List<Widget> actions = [];

    if (!widget.isEditing) {
      // 편집 코글때 숨겨
      actions.addAll([
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/search');
          },
          child: SvgPicture.asset(
            IconPaths.getIcon('search'),
          ),
        ),
      ]);
    }
    // 검색이랑 편집 버튼 사이
    actions.add(const SizedBox(width: 16));

    // Edit button
    actions.add(
      GestureDetector(
        onTap: widget.onToggleEditing,
        child: Container(
          width: 55,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Color(0xFFE1E1E1), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.isEditing ? '완료' : '편집',
            style: const TextStyle(
              color: Color(0xFF00376E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // MY button (hidden when editing)
    if (!widget.isEditing) {
      actions.add(
        const SizedBox(width: 16),
      );
      actions.add(
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/my');
          },
          child: const Text(
            'MY',
            style: TextStyle(
              color: Color(0xFF00376E),
              fontSize: 19,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return actions;
  }
}
