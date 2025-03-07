import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class DeletePage extends StatelessWidget {
  final String userId = Get.arguments['userId'];

  DeletePage({Key? key}) : super(key: key);

  Future<void> _confirmDeletion(BuildContext context) async {
    bool success = await ApiService.deleteUser(userId);
    if (success) {
      Get.offAllNamed('/signin');
    } else {
      Get.offAllNamed('/signin');
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
          children: [
            // Top Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 큰
                  Text.rich(
                    TextSpan(
                      text: '탈퇴 하시면, 지금까지 저장한\n모든 콘텐츠가',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Seven',
                        height: 1.25,
                      ),
                      children: [
                        TextSpan(
                          text: ' 영영 사라져요 :(',
                          style: TextStyle(
                            color: Color(0xFFCD423D),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),

                  // 회색 글
                  Text(
                    '탈퇴 시 계정 및 이용 기록은 모두 삭제되며,\n삭제된 데이터는 복구가 불가능해요.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Five',
                      color: Colors.grey,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 40.h),

                  // 피드백 컨테이너띠띠
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
                          SvgPicture.asset(IconPaths.getIcon('my_logo')),
                          SizedBox(width: 13.w),
                          Text.rich(
                            TextSpan(
                              text: '루트를 탈퇴하시는 이유를 알려주세요.',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Six',
                              ),
                              children: [
                                TextSpan(
                                  text: '\n더 개선된 루트로 돌아올게요!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Four',
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          SvgPicture.asset(
                              IconPaths.getIcon('double_arrow_dark'),
                              fit: BoxFit.contain),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 맨 및 탈퇴하기 button
            Padding(
              padding: EdgeInsets.only(bottom: 19.h),
              child: ElevatedButton(
                onPressed: () => _confirmDeletion(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2960C6),
                  fixedSize: Size(284, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                child: Text('탈퇴하기', style: TextStyle(color: Colors.white)),
              ),
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
