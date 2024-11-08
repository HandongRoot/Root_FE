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
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Update UI when text changes
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
                    "컨텐츠 제목 변경",
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 22 / 17,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 232,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 18 / 11,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 10,
                          ),
                          onPressed: () => _controller.clear(),
                        ),
                      ),
                    ),
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
                          textBaseline: TextBaseline.alphabetic,
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
                    onTap: _controller.text.isNotEmpty
                        ? () {
                            widget.onSave(_controller.text);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: Text(
                        "저장",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          color: _controller.text.isEmpty
                              ? Colors.grey
                              : Color(0xFF007AFF),
                          height: 22 / 17,
                          textBaseline: TextBaseline.alphabetic,
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
