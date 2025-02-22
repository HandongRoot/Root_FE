import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              '마이페이지',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Six',
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 10.w),
                child: IconButton(
                  icon: SvgPicture.asset(IconPaths.getIcon('my_x')),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  },
                  padding: EdgeInsets.zero,
                ),
              )
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
                          fontSize: 22,
                          fontFamily: 'Five',
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        email!,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Three',
                          color: Colors.grey,
                        ),
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
                      color: Color(0xFF7699DA),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '전달하고 싶은 피드백이 있나요?\n피드백 창구를 활용해보세요!',
                          style: TextStyle(
                            color: Colors.white,
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
                SizedBox(height: 15.h),
                //_buildInfoSection('개인정보 처리방침', 'https://www.example.com/privacy-policy'),
                _buildInfoSection('개인정보 처리방침',
                    'data:image/jpeg;base64,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'),
                SizedBox(height: 15.h),
                //_buildInfoSection('서비스 이용 약관', 'https://www.example.com/terms-of-service'),
                _buildInfoSection('서비스 이용 약관',
                    'data:image/jpeg;base64,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'),
                SizedBox(height: 40.h),
                Text(
                  '계정',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Five',
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildInfoSection('로그아웃',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzqxUmINzJErM3R27P1ivdIV4crKDmZ-uJIA&s'),
                SizedBox(height: 15.h),
                _buildInfoSection('탈퇴하기',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQA-3rYxavsEH5kmRPAVNA1J8G0EHgknwnhMg&s'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
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
                fontSize: 16,
                fontFamily: 'Four',
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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
