import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart'; // 📌 추가됨

class SharedModal extends StatelessWidget {
  final String sharedUrl;

  const SharedModal({Key? key, required this.sharedUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> folders = ["자기계발", "영어공부", "밈 모음집", "뉴진스", "음식리스트"];

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 헤더: 닫기(X) 왼쪽, 제목 중앙, 추가 버튼 오른쪽
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: SvgPicture.asset(IconPaths.getIcon('my_x')),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 14, height: 14),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "저장할 위치 선택하기",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 22 / 17,
                  fontFamily: 'Pretendard',
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: "추가" 버튼 기능 추가 가능
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 22),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "추가",
                  style: TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 22 / 13,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 🔹 폴더 리스트 (가로 스크롤)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: folders.map((folder) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        "assets/ShareFolder.svg", // 📌 폴더 아이콘
                        width: 55,
                        height: 55,
                      ),
                      SizedBox(height: 8),
                      Text(
                        folder,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 22 / 12,
                          fontFamily: 'Pretendard',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 16),

          // 🔹 구분선 추가
          Divider(thickness: 1, color: Colors.grey[300]), // 📌 구분선 추가

          SizedBox(height: 16),

          // 🔹 "전체 리스트에 저장" 버튼 (텍스트 왼쪽, 아이콘 오른쪽)
          ElevatedButton(
            onPressed: () {
              // TODO: 저장 기능 추가 가능
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              padding: EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 추가
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 왼쪽, 아이콘 오른쪽
              children: [
                Text("전체 리스트에 저장", style: TextStyle(fontSize: 16)), // 📌 왼쪽 정렬 텍스트
                SvgPicture.asset(
                  IconPaths.getIcon('grid'), // 📌 오른쪽 정렬 아이콘
                  fit: BoxFit.contain,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
