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

  Future<void> _setFirstTimeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // 딱 한번만
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
                SvgPicture.asset(
                  IconPaths.getIcon('one'),
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 46.w)
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
    );
  }
}
