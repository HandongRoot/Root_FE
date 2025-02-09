import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp, // Responsive font size
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
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
        padding: EdgeInsets.all(20.w), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '김예정님',
              style: TextStyle(
                fontSize: 22.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'yejomee22@gmail.com',
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40.h),

            // Feedback Section
            Container(
              height: 87.h,
              padding: EdgeInsets.all(21.w),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 93, 119, 168),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '전달하고 싶은 피드백이 있나요?\n피드백 창구를 활용해보세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Icon(Icons.email_rounded, size: 54.sp, color: Colors.white),
                  SizedBox(width: 9.w),
                  Icon(Icons.keyboard_double_arrow_right_outlined,
                      color: Colors.white),
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

            Column(
              children: [
                // Privacy Policy
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 22.h,
                    horizontal: 19.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '개인정보 처리방침',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),

                // Terms of Service
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 22.h,
                    horizontal: 19.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '서비스 이용 약관',
                        style: TextStyle(
                          fontSize: 16.sp,
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

            Column(
              children: [
                // Logout
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 22.h,
                    horizontal: 19.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),

                // Delete Account
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 22.h,
                    horizontal: 19.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(248, 248, 250, 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '탈퇴하기',
                        style: TextStyle(
                          fontSize: 16.sp,
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
