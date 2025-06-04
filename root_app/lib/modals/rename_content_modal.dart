import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:root_app/controllers/folder_controller.dart';

class RenameContentModal extends StatefulWidget {
  final String initialTitle;
  final Function(String) onSave;

  const RenameContentModal({
    super.key,
    required this.initialTitle,
    required this.onSave,
  });

  @override
  RenameContentModalState createState() => RenameContentModalState();
}

class RenameContentModalState extends State<RenameContentModal> {
  late TextEditingController _controller;
  final folderController = Get.find<FolderController>();

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
                    fontFamily: 'Five',
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
            SizedBox(
              height: 39,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "취소",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Three',
                            color: Color(0xFF007AFF),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: Color.fromRGBO(60, 60, 67, 0.36),
                    thickness: 0.5,
                    width: 0.5,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          widget.onSave(_controller.text);
                          folderController.loadFolders();
                          Get.back();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "저장",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Three',
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
