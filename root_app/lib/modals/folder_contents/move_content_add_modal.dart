import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:root_app/main.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/utils/content_change_util.dart';

class MoveContentAddNewFolderModal extends StatefulWidget {
  final TextEditingController controller;
  final Map<String, dynamic>? content;
  final List<Map<String, dynamic>>? contents;

  const MoveContentAddNewFolderModal({
    Key? key,
    required this.controller,
    this.content,
    this.contents, // Add this line
  }) : super(key: key);

  @override
  _MoveContentAddNewFolderModalState createState() =>
      _MoveContentAddNewFolderModalState();
}

class _MoveContentAddNewFolderModalState
    extends State<MoveContentAddNewFolderModal> {
  bool isTextEntered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.clear();
    widget.controller.addListener(() {
      setState(() {
        isTextEntered = widget.controller.text.isNotEmpty;
      });
    });
  }

  Future<Map<String, String>?> _createFolder() async {
    final String title = widget.controller.text;
    if (title.isEmpty) return null;
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return null;
    }
    final String url = '$baseUrl/api/v1/category';
    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'title': title,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String newCategoryId = utf8.decode(response.bodyBytes).trim();
        print("📂 New Category ID: $newCategoryId");
        return {
          'newCategoryId': newCategoryId,
        };
      } else {
        print('❌ Failed to create folder: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating folder: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: AppTheme.primaryColor,
      child: Container(
        width: 270,
        height: 146,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Column(
              children: [
                Text(
                  "새로운 폴더",
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Six',
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  "새로운 폴더의 제목을 입력해주세요.",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Four',
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 232,
                  height: 26,
                  child: TextField(
                    controller: widget.controller,
                    decoration: InputDecoration(
                      hintText: "제목",
                      hintStyle: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Four',
                        color: AppTheme.textColor,
                      ),
                      contentPadding: const EdgeInsets.all(7),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.buttonColor,
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Four',
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Divider(height: 0.5, color: AppTheme.buttonDividerColor),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Four',
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 42.5,
                  color: AppTheme.buttonDividerColor,
                ),
                Expanded(
                  child: InkWell(
                    onTap: isTextEntered
                        ? () async {
                            final result = await _createFolder();
                            if (result != null) {
                              final newCategoryId = result['newCategoryId'];

                              final List<String> contentIds = [];
                              if (widget.content != null) {
                                contentIds
                                    .add(widget.content!['id'].toString());
                              } else if (widget.contents != null &&
                                  widget.contents!.isNotEmpty) {
                                contentIds.addAll(widget.contents!
                                    .map((c) => c['id'].toString()));
                              }

                              if (contentIds.isEmpty) {
                                return; // No content to move
                              }

                              final String beforeCategoryId = widget
                                      .content?['categories']?['id']
                                      ?.toString() ??
                                  '0';

                              // 선택한 콘첸츠 새로운 폴더로 move
                              final success = await changeContentToFolder(
                                  contentIds, beforeCategoryId, newCategoryId!);

                              if (success) {
                                Get.back();
                                Get.back();
                              } else {
                                print("❌ Failed to move content.");
                              }
                            }
                          }
                        : null,
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: Text(
                        "저장",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Four',
                          color: isTextEntered
                              ? AppTheme.secondaryColor
                              : AppTheme.accentColor.withOpacity(0.5),
                          height: 22 / 17,
                        ),
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
