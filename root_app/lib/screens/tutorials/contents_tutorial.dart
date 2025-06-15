import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentsTutorial extends StatefulWidget {
  const ContentsTutorial({super.key});

  @override
  ContentsTutorialState createState() => ContentsTutorialState();
}

class ContentsTutorialState extends State<ContentsTutorial> {
  @override
  void initState() {
    super.initState();
    _setFirstTimeFlag();
  }

  Future<void> _setFirstTimeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeFolder', false); // 딱 한번만
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(181, 0, 0, 0),
      body: SizedBox.expand(
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
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                Column(
                  children: [
                    SizedBox(height: 19.h),
                    SvgPicture.asset(
                      IconPaths.getIcon('four'),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(width: 13.w),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
