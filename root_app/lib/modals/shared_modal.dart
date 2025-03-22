import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';

class SharedModal extends StatelessWidget {
  final String sharedUrl;

  const SharedModal({Key? key, required this.sharedUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> folders = [
      "자기계발", "영어공부", "밈 모음집", "뉴진스", "음식리스트",
      "바보", "멍청이", "똥개", "해삼", "말미잘"
    ]; // 📌 폴더 개수 확장

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 헤더: 닫기(X) 왼쪽, 제목 중앙, 추가 버튼 오른쪽
          Row(
            children: [
              Transform.translate(
                offset: Offset(-7, 0),
                child: IconButton(
                  icon: SvgPicture.asset(IconPaths.getIcon('my_x')),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 14, height: 14), // 크기 14px 유지
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Text(
                  "저장할 위치 선택하기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 22 / 17,
                    fontFamily: 'Pretendard',
                  ),
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

          SizedBox(height: 18),

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
                        "assets/ShareFolder.svg",
                        width: 55,
                        height: 55,
                      ),
                      SizedBox(height: 8),
                      // 🔹 폴더 이름 스타일 적용
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

          SizedBox(height: 25),

          // 🔹 구분선 추가 (두께 0.7로 변경)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2), // 좌우 패딩 추가
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: double.infinity,
                height: 0.7,
                color: Colors.grey[300],
              ),
            ),
          ),

          SizedBox(height: 20),

          // 🔹 "전체 리스트에 저장" 버튼 (텍스트 왼쪽, 아이콘 오른쪽)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF2074F4), Color(0xFF34D1FB)],
              ),
            ),
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "전체 리스트에 저장",
                    style: TextStyle(
                      color: Color(0xFFFCFCFC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 22 / 14,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SvgPicture.asset(
                    IconPaths.getIcon('grid'),
                    fit: BoxFit.contain,
                    width: 16,
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
