import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 화면을 흰색으로
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          // 세로 방향으로 위젯을 배치
          children: [
            // 로고 영역
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/ROOT.svg', // 실제 로고 경로
                  width: 120, // 원하는 크기로 조절
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // 카카오 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 카카오 로그인 로직
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline, // 실제 카카오 아이콘 대신 예시
                        color: Colors.black,
                      ),
                      label: const Text(
                        '카카오로 시작하기',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFEE500), // 카카오 버튼 컬러
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Apple 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Apple 로그인 로직
                      },
                      icon: const Icon(
                        Icons.apple, // 실제 Apple 아이콘 대신 예시
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Apple로 시작하기',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black, // Apple 버튼 컬러
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
