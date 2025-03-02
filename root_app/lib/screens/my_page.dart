import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPage extends StatefulWidget {
  final String userId;

  const MyPage({required this.userId});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await ApiService.fetchUserData(widget.userId);
    if (data != null) {
      setState(() {
        name = data['name'];
        email = data['email'];
      });
    }
  }

  Future<void> logoutUser() async {
    bool success = await ApiService.logoutUser(widget.userId);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
  }

  Future<void> deleteUser() async {
    bool success = await ApiService.deleteUser(widget.userId);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/signin');
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
                    Get.back();
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
                _buildInfoSection('로그아웃', ''),
                SizedBox(height: 15.h),
                _buildInfoSection('탈퇴하기', ''),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String url) {
    return GestureDetector(
      onTap: () async {
        if (title == '로그아웃') {
          await logoutUser();
        } else if (title == '탈퇴하기') {
          await deleteUser();
        } else {
          if (url.isNotEmpty) {
            _launchURL(url);
          }
        }
      },
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

void showMyPage(BuildContext context, {required String userId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: MyPage(userId: userId),
    ),
  );
}
