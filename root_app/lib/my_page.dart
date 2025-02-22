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
                _buildInfoSection('개인정보 처리방침',
                    'https://lake-breath-037.notion.site/root-17fafbeda14880f1ae1deb5c20d216d1'),
                SizedBox(height: 15.h),
                _buildInfoSection('서비스 이용 약관',
                    'https://lake-breath-037.notion.site/root-17fafbeda148801497a9e717309a57b4?pvs=74'),
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
