import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 이미지 사용

class SharedModal extends StatelessWidget {
  final String sharedUrl; // 현재는 사용되지 않음 (숨김 처리)

  const SharedModal({Key? key, required this.sharedUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> folders = ["자기계발", "영어공부", "밈 모음집", "뉴진스", "음식리스트"];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 헤더: 닫기(X) 버튼 왼쪽, 제목 중앙, 추가 버튼 오른쪽
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close), // 🔹 닫기 버튼을 왼쪽으로 이동
                onPressed: () => Navigator.pop(context),
              ),
              Text("저장할 위치 선택하기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // TODO: "추가" 버튼 기능 추가
                },
                child: Text("추가", style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 🔹 URL 숨김 (삭제됨)

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
                        "assets/ShareFolder.svg", // 📌 폴더 아이콘 변경
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(height: 8),
                      Text(folder, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 16),

          // 🔹 "전체 리스트에 저장" 버튼
          ElevatedButton(
            onPressed: () {
              // TODO: 폴더 선택 후 저장 로직 추가 가능
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text("전체 리스트에 저장"),
          ),
        ],
      ),
    );
  }
}
