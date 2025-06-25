import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:root_app/screens/my_page/my_page.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GalleryAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final bool isSelecting;
  final Function(bool)? onSelectionModeChanged;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onClearActiveContent;

  const GalleryAppBar({
    this.height = 56,
    required this.isSelecting,
    this.onSelectionModeChanged,
    this.onDeletePressed,
    this.onClearActiveContent,
    super.key,
  });

  @override
  GalleryAppBarState createState() => GalleryAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}

class GalleryAppBarState extends State<GalleryAppBar> {
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
/*
              // FIRST TIME TUTORIAL 테스트용
              ElevatedButton(
                onPressed: () async {
                  await resetFirstTimeFlag();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF54D1C9),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  elevation: 4,
                ),
                child: const Text('투토리얼 리셋'),
              ),
              
              ElevatedButton(
                onPressed: () {
                  sendSharedDataToBackend(
                    '러키비통',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNCe1QOHfbzbzjvLL7z2V8Wadcr_aDpqZYxQ&s',
                    'https://youtu.be/ooOELrGMn14?si=VxXSjy5DT7Gzilsv',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4da2d9),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  elevation: 4,
                ),
                child: const Text('+'),
              ),
              */
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
        onPressed: () => Get.toNamed('/search'),
        padding: EdgeInsets.zero,
        // effect 다 빼기
        style: ButtonStyle().copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
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
        widget.onClearActiveContent?.call();
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
            color: Color(0xFF2960C6),
            fontSize: 13,
            fontFamily: 'Four',
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
        showMyPage(context);
      },
      padding: EdgeInsets.zero,
      // effect 다 빼기
      style: ButtonStyle().copyWith(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
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
            fontFamily: 'Five',
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
            color: Color(0xFF2960C6),
            fontSize: 13,
            fontFamily: 'Five',
            letterSpacing: 0.1.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
