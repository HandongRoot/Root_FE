import 'package:flutter/material.dart';
import 'package:root_app/main.dart';
import 'package:root_app/my_page.dart';
import 'package:root_app/utils/icon_paths.dart';
import '../styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GalleryAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final bool isSelecting;
  final Function(bool)? onSelectionModeChanged;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onClearActiveItem;

  const GalleryAppBar({
    this.height = 56,
    required this.isSelecting,
    this.onSelectionModeChanged,
    this.onDeletePressed,
    this.onClearActiveItem,
    Key? key,
  }) : super(key: key);

  @override
  _GalleryAppBarState createState() => _GalleryAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}

class _GalleryAppBarState extends State<GalleryAppBar> {
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
          fit: BoxFit.none,
        ),
        onPressed: () => Navigator.pushNamed(context, '/search'),
        padding: EdgeInsets.zero,
      ),
      SizedBox(width: 1.5.w),
      _buildSelectButton(),
      SizedBox(width: 2.w),
      _buildMyButton(),
    ];
  }

  List<Widget> _buildSelectionActions() {
    return [
      _buildDeleteButton(),
      SizedBox(width: 12.w),
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
        width: 55,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: const Color(0xFFE1E1E1), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Text(
          '선택',
          style: TextStyle(
            color: Color(0xFF00376E),
            fontSize: 13,
            fontFamily: 'four',
            letterSpacing: 0.1.sp,
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
        fit: BoxFit.none,
      ),
      onPressed: () {
        showMyPageModal(context, userId: userId);
      },
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () {
        widget.onDeletePressed?.call();
      },
      child: Container(
        width: 55,
        height: 30.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: const Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: Text(
          '삭제',
          style: TextStyle(
            color: Color(0xFFDC3E45),
            fontSize: 13,
            fontFamily: 'five',
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
        width: 55,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: const Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: Text(
          '완료',
          style: TextStyle(
            color: Color(0xFF00376E),
            fontSize: 13,
            fontFamily: 'five',
            letterSpacing: 0.1.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
