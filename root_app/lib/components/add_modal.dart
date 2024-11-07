import 'package:flutter/material.dart';

class AddModal extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const AddModal({
    Key? key,
    required this.controller,
    required this.onSave,
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
                  const Text(
                    "새로운 폴더",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "새로운 폴더의 제목을 입력해주세요.",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 232,
                      height: 26,
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: "제목",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
                      onSave();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: const Text(
                        "저장",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFB0B0B0),
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
