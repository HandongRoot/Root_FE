import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:root_app/screens/search_page.dart';
import 'package:root_app/utils/icon_paths.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // 1) Center 대신 Column으로 전체 화면을 채우고 싶다면 Center 제거
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            // mainAxisSize: MainAxisSize.min, // <-- 제거 또는 주석 처리
            children: [
              Spacer(),
              // 2) 로고 영역
              SizedBox(
                width: 131.9,
                height: 88.14,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                  ),
                ),
              ),
              Spacer(),
              // 3) 버튼들
              ElevatedButton(
                onPressed: () {
                  // TODO: 카카오톡 로그인 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  fixedSize: Size(350.w, 59),
                  padding: EdgeInsets.symmetric(vertical: 19, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        IconPaths.getIcon('kakao'),
                      ),
                    ),
                    Spacer(),
                    const Text(
                      '카카오로 시작하기',
                      style: TextStyle(
                        color: Color(0xFF191600),
                        fontFamily: 'Six',
                        fontSize: 17.5,
                        height: 1.0,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 9),
              ElevatedButton(
                onPressed: () {
                  // TODO: Apple로 로그인 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(350.w, 59),
                  padding: EdgeInsets.symmetric(vertical: 19, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.apple,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    const Text(
                      'Apple로 시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Five',
                        fontSize: 17.5,
                        height: 1.0,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 58.h),
            ],
          ),
        ),
      ),
    );
  }
}
