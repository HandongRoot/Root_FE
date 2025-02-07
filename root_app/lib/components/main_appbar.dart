import 'package:flutter/material.dart';
import 'package:root_app/utils/icon_paths.dart';
import '../styles/colors.dart';

// 우리 아이콘 쓰는용
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/icon_paths.dart';

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
        IconButton(
          icon: SvgPicture.asset(
            IconPaths.getIcon('search'),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
        ),
      ]);
    }
    // 검색이랑 편집 버튼 사이
    //TODO 수정띠띠
    //actions.add(const SizedBox(width: 4));

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
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // MY button (hidden when editing)
    if (!widget.isEditing) {
      //TODO 수정띠띠
      actions.add(
        const SizedBox(width: 8),
      );
      actions.add(IconButton(
        icon: SvgPicture.asset(
          IconPaths.getIcon('my'),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/my');
        },
      ));
    }

    return actions;
  }
}
