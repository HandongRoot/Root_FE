import 'package:flutter/material.dart';

class ModifyModal extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSave;

  const ModifyModal({
    Key? key,
    required this.initialTitle,
    required this.onSave,
  }) : super(key: key);

  @override
  _ModifyModalState createState() => _ModifyModalState();
}

class _ModifyModalState extends State<ModifyModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "컨텐츠 제목 변경",
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      widget.onSave(_controller.text);
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
                          color: Colors.grey, // 회색으로 초기화
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
