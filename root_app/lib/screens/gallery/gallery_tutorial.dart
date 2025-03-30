import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryTutorial extends StatefulWidget {
  @override
  _GalleryTutorialState createState() => _GalleryTutorialState();
}

class _GalleryTutorialState extends State<GalleryTutorial> {
  @override
  void initState() {
    super.initState();
    _setFirstTimeFlag();
  }

  Size get preferredSize => Size.fromHeight(56.0);

  Future<void> _setFirstTimeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // 딱 한번만
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// 🔵 Top Row with Fixed Height (56)
                SizedBox(
                  height: 56,
                  child: Row(
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
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              IconPaths.getIcon('search'),
                              fit: BoxFit.none,
                            ),
                            onPressed: () => Get.toNamed('/search'),
                            padding: EdgeInsets.zero,
                            style: ButtonStyle().copyWith(
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),
                          Container(
                            width: 55,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.r),
                              border: Border.all(
                                  color: const Color(0xFFE1E1E1), width: 1.2),
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
                          SvgPicture.asset(
                            IconPaths.getIcon('my'),
                            fit: BoxFit.none,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SvgPicture.asset(
                    'assets/tutorialGallery.svg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          /// 🔵 Dark Overlay
          Positioned.fill(
            child: Container(
              color: Color.fromARGB(181, 0, 0, 0),
            ),
          ),

          /// ⚪ Foreground UI (Your tutorial content)
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 20.w),
                    IconButton(
                      icon: SvgPicture.asset(
                        IconPaths.getIcon('x_white'),
                        fit: BoxFit.none,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    Spacer(),
                    SvgPicture.asset(
                      IconPaths.getIcon('one'),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 46.w),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      IconPaths.getIcon('two'),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                Spacer(),
                SvgPicture.asset(
                  IconPaths.getIcon('three'),
                  fit: BoxFit.contain,
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
