import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemoveContent extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onDelete;

  const RemoveContent({
    super.key,
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryName = content['categories'] != null
        ? content['categories']['title'].toString()
        : 'Unknown Category';

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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "‘$categoryName’ 폴더에서 삭제",
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: 'Six',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "콘텐츠를 삭제하시겠습니까?",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Four',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              width: double.infinity,
              color: const Color.fromRGBO(60, 60, 67, 0.36),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Three',
                          color: Color(0xFF007AFF),
                          height: 22 / 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 42.5,
                  color: const Color.fromRGBO(60, 60, 67, 0.36),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onDelete();
                      Get.back();
                    },
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: const Text(
                        "삭제",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Three',
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
