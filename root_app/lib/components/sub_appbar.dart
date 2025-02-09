import 'package:flutter/material.dart';
import 'package:root_app/utils/icon_paths.dart';
import '../styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final bool isSelecting;
  final Function(bool)? onSelectionModeChanged;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onClearActiveItem;

  const SubAppBar({
    this.height = 56,
    required this.isSelecting,
    this.onSelectionModeChanged,
    this.onDeletePressed,
    this.onClearActiveItem,
    Key? key,
  }) : super(key: key);

  @override
  _SubAppBarState createState() => _SubAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height.h); // Responsive height
}

class _SubAppBarState extends State<SubAppBar> {
  bool isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: 30.w, // Responsive width
                height: 22.h, // Responsive height
                fit: BoxFit.contain,
              ),
            ],
          ),
          Row(
            children: widget.isSelecting
                ? _buildSelectionActions()
                : _buildDefaultActions(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        icon: SvgPicture.asset(
          IconPaths.getIcon('search'),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      _buildSelectButton(),
      SizedBox(width: 8.w), // Responsive spacing
      _buildMyButton(),
    ];
  }

  List<Widget> _buildSelectionActions() {
    return [
      _buildDeleteButton(),
      SizedBox(width: 12.w), // Responsive spacing
      _buildCompleteButton(),
    ];
  }

  Widget _buildSelectButton() {
    return GestureDetector(
      onTap: () {
        widget.onClearActiveItem?.call();
        widget.onSelectionModeChanged?.call(true);
      },
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
          '선택',
          style: TextStyle(
            color: Color(0xFF00376E),
            fontSize: 13.sp, // Responsive font size
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1.sp, // Responsive letter spacing
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMyButton() {
    return IconButton(
      icon: SvgPicture.asset(
        IconPaths.getIcon('my'),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/my');
      },
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () {
        widget.onDeletePressed?.call();
      },
      child: Container(
        width: 55.w, // Responsive width
        height: 30.h, // Responsive height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: const Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: Text(
          '삭제',
          style: TextStyle(
            color: Color(0xFFDC3E45),
            fontSize: 13.sp, // Responsive font size
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelecting = false;
        });
        widget.onSelectionModeChanged?.call(false);
      },
      child: Container(
        width: 55.w, // Responsive width
        height: 30.h, // Responsive height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: const Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: Text(
          '완료',
          style: TextStyle(
            color: Color(0xFF00376E),
            fontFamily: 'Pretendard',
            fontSize: 13.sp, // Responsive font size
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
