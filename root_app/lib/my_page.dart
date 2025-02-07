import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        // 내릴때 색 변하는거 방지
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme:
            const IconThemeData(color: Colors.black), // Back button color
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Make the page scrollable
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 이멜멜
            const Text(
              '김예정님',
              style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            const Text(
              'yejomee22@gmail.com',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w300,
                  color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // 피드백
            Container(
              height: 87,
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                //TODO 예정이한테 물어보기
                color: const Color.fromARGB(255, 93, 119, 168),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '전달하고 싶은 피드백이 있나요?\n피드백 창구를 활용해보세요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 18),
                  Icon(Icons.email_rounded, size: 54, color: Colors.white),
                  SizedBox(width: 9),
                  Icon(Icons.keyboard_double_arrow_right_outlined,
                      color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 41),

            // Guidance Section
            const Text(
              '이용 안내',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                // 개인정보 처리방침
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 19,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '개인정보 처리방침',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // 서비스 이용 약관
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 19,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '서비스 이용 약관',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // 계정정
            const Text(
              '계정',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 15),
            // 로그아웃 / 탈퇴하기
            Column(
              children: [
                // 로그아웃
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 19,
                  ), // Spacing between containers
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                // 탈퇴하기
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 19,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '탈퇴하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
