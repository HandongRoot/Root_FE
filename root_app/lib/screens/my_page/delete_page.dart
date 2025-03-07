import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class DeletePage extends StatelessWidget {
  // Get the userId from the navigation arguments
  final String userId = Get.arguments['userId'];

  DeletePage({Key? key}) : super(key: key);

  // Function to handle account deletion
  Future<void> _confirmDeletion(BuildContext context) async {
    bool success = await ApiService.deleteUser(userId);
    if (success) {
      Get.offAllNamed('/signin'); // Navigate to sign-in if successful
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정 삭제에 실패했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset(IconPaths.getIcon('back')),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Six',
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Text Part
                Text.rich(
                  TextSpan(
                    text: '탈퇴 하시면, 지금까지 저장한\n모든 콘텐츠가',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontFamily: 'Five',
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: ' 영영 사라져요 :(',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5.h),

// Second Text Part
                Text(
                  '탈퇴 시 계정 및 이용 기록은 모두 삭제되며,\n삭제된 데이터는 복구가 불가능해요.',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Three',
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40.h),
            InkWell(
              onTap: () {
                _launchURL('https://tally.so/r/mBjO91');
              },
              child: Container(
                height: 87,
                width: 350.w,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      '전달하고 싶은 피드백이 있나요?\n피드백 창구를 활용해보세요!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Six',
                      ),
                    ),
                    Spacer(),
                    Image.asset('assets/icons/message.png'),
                    SizedBox(width: 16.w),
                    SvgPicture.asset(IconPaths.getIcon('double_arrow'),
                        fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
            SizedBox(height: 41.h),
            Text(
              '이용 안내',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Five',
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _confirmDeletion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 33, 219),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('탈퇴하기', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
