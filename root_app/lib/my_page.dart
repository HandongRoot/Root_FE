import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPageContent extends StatefulWidget {
  final String userId;

  const MyPageContent({required this.userId});

  @override
  _MyPageContentState createState() => _MyPageContentState();
}

class _MyPageContentState extends State<MyPageContent> {
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// Fetch user data from the backend using the passed userId.
  Future<void> fetchUserData() async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    final String endpoint = '/api/v1/user/${widget.userId}';
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {"Accept": "*/*"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          name = data['name'];
          email = data['email'];
        });
      } else {
        print(
            "Failed to load user data. Request URL: $requestUrl, Status Code: ${response.statusCode}");
        throw Exception("Failed to load user data from $requestUrl");
      }
    } catch (e) {
      print("Error fetching data from $requestUrl: $e");
      throw Exception("Failed to load user data from $requestUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set modal height based on screen height with a maximum limit.
    double modalHeight = 0.7.sh;
    if (modalHeight > 606.h) {
      modalHeight = 606.h;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          // The modal's top corners are rounded in the modal function.
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              '마이페이지',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  IconPaths.getIcon('my_x'),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name != null && email != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name!,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        email!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 40.h),
                // Feedback Section
                Container(
                  height: 87.h,
                  width: 350.w,
                  padding: EdgeInsets.all(21.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF7699DA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '전달하고 싶은 피드백이 있나요?\n피드백 창구를 활용해보세요!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 36.w),
                      // Use a PNG for message icon if needed:
                      Image.asset(
                        'assets/icons/message.png',
                        width: 35.w,
                        height: 31.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 19.w),
                      SvgPicture.asset(
                        IconPaths.getIcon('double_arrow'),
                        width: 24.w,
                        height: 24.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 41.h),
                // Guidance Section
                Text(
                  '이용 안내',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildInfoSection('개인정보 처리방침'),
                SizedBox(height: 15.h),
                _buildInfoSection('서비스 이용 약관'),
                SizedBox(height: 40.h),
                // Account Section
                Text(
                  '계정',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildInfoSection('로그아웃'),
                SizedBox(height: 15.h),
                _buildInfoSection('탈퇴하기'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 19.w),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(248, 248, 250, 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

void showMyPageModal(BuildContext context, {required String userId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: MyPageContent(userId: userId),
    ),
  );
}
