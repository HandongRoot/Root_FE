import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
              // 2) 로고 영역
              Expanded(
                child: Center(
                  child: SvgPicture.asset(
                    IconPaths.getIcon('ROOT'), // 실제 SVG 경로
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 3) 버튼들
              ElevatedButton(
                onPressed: () {
                  // TODO: 카카오톡 로그인 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE500),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 19,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: const Color(0xFF191600),
                      ),
                    ),
                    const Text(
                      '카카오톡으로 시작하기',
                      style: TextStyle(
                        color: Color(0xFF191600),
                        fontFamily: 'Pretendard Variable',
                        fontSize: 17.5,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // TODO: Apple 로그인 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 19,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.apple,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Apple로 시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard Variable',
                        fontSize: 17.5,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
