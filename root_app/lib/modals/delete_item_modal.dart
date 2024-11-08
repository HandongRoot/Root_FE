import 'package:flutter/material.dart';

class DeleteItemModal extends StatelessWidget {
  final Map<String, dynamic> item; // 삭제할 아이템 정보 (item parameter 사용)
  final VoidCallback onDelete; // 삭제 콜백

  const DeleteItemModal({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "‘${item['title']}’ 삭제", // 삭제할 항목의 제목 표시
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "콘텐츠를 삭제하시겠습니까?", // 삭제 확인 메시지
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // 취소 삭제 버튼 버튼 위헤
            Container(
              height: 0.5,
              width: double.infinity,
              color: const Color.fromRGBO(60, 60, 67, 0.36),
            ),
            // 취소 삭제 버튼 들어있는 row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF007AFF),
                          height: 22 / 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // 취소 삭제 버튼 사이 그 선.
                Container(
                  width: 0.5,
                  height: 42.5,
                  color: const Color.fromRGBO(60, 60, 67, 0.36),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onDelete(); // 삭제 로직 실행 (콜백 호출)
                      Navigator.of(context).pop(); // 모달 닫기
                    },
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: const Text(
                        "삭제",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFF2828),
                          height: 22 / 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
