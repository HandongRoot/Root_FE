import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RenameModal extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSave;

  const RenameModal({
    Key? key,
    required this.initialTitle,
    required this.onSave,
  }) : super(key: key);

  @override
  _RenameModalState createState() => _RenameModalState();
}

class _RenameModalState extends State<RenameModal> {
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
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "콘탠츠 제목 변경",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // 제목
                Container(
                  height: 26,
                  width: 232,
                  margin: const EdgeInsets.all(4),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "새로운 제목 입력",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 0.5,
              width: double.infinity,
              color: const Color.fromRGBO(60, 60, 67, 0.36),
            ),
            Container(
              height: 39, // Set the height for the row
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "취소", // Cancel button
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
                  // Add Vertical Divider
                  const VerticalDivider(
                    color: Color.fromRGBO(60, 60, 67, 0.36), // Divider color
                    thickness: 0.5, // Divider thickness
                    width: 0.5, // Space taken by the divider
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          widget.onSave(_controller.text);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "저장",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            color: _controller.text.isNotEmpty
                                ? const Color(0xFF007AFF)
                                : const Color(0xFFB0B0B0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
