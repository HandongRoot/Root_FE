import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:root_app/main.dart';
import 'package:root_app/screens/my_page/my_page.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  Size get preferredSize => Size.fromHeight(56.0);
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
                width: 72,
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
      actions.addAll([
        IconButton(
          icon: SvgPicture.asset(
            IconPaths.getIcon('search'),
            fit: BoxFit.none,
          ),
          onPressed: () => Get.toNamed('/search'),
          padding: EdgeInsets.zero,
          // effect 다 빼기
          style: ButtonStyle().copyWith(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ]);
    }

    actions.add(SizedBox(width: 1.5.w));

    // Edit button
    actions.add(
      GestureDetector(
        onTap: widget.onToggleEditing,
        child: Container(
          width: 55,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(color: const Color(0xFFE1E1E1), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.isEditing ? '완료' : '편집',
            style: TextStyle(
              color: const Color(0xFF2960C6),
              fontSize: 13,
              fontFamily: 'Three',
              letterSpacing: 0.1.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // MY
    if (!widget.isEditing) {
      actions.add(SizedBox(width: 2.w));
      actions.add(IconButton(
        icon: SvgPicture.asset(
          IconPaths.getIcon('my'),
          fit: BoxFit.none,
        ),
        onPressed: () {
          showMyPage(context);
        },
        padding: EdgeInsets.zero,
        // effect 다 빼기
        style: ButtonStyle().copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ));
    }

    return actions;
  }
}
