import 'package:flutter/material.dart';

class DeleteModal extends StatelessWidget {
  final String category;
  final VoidCallback onDelete;

  const DeleteModal({
    Key? key,
    required this.category,
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Subtitle
            Column(
              children: [
                Text(
                  "‘$category’ 삭제",
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 22 / 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "‘$category’ 폴더를 삭제하시겠습니까?",
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    height: 18 / 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider line
            Container(
              height: 0.5,
              color: const Color.fromRGBO(60, 60, 67, 0.36),
            ),
            // Action buttons in a row
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 11),
                      child: Text(
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
                // Vertical divider
                Container(
                  width: 0.5,
                  height: 48,
                  color: const Color.fromRGBO(60, 60, 67, 0.36),
                ),
                // Delete button
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onDelete();
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 11),
                      child: Text(
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
