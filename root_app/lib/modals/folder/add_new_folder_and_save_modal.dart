import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:root_app/main.dart';
import 'package:root_app/theme/theme.dart';

class AddNewFolderAndSaveModal extends StatefulWidget {
  final String contentTitle;
  final String thumbnail;
  final String linkedUrl;

  const AddNewFolderAndSaveModal({
    Key? key,
    required this.contentTitle,
    required this.thumbnail,
    required this.linkedUrl,
  }) : super(key: key);

  @override
  State<AddNewFolderAndSaveModal> createState() =>
      _AddNewFolderAndSaveModalState();
}

class _AddNewFolderAndSaveModalState extends State<AddNewFolderAndSaveModal> {
  final TextEditingController controller = TextEditingController();
  bool isTextEntered = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        isTextEntered = controller.text.isNotEmpty;
      });
    });
  }

  Future<void> createFolderAndSaveContent() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final String folderTitle = controller.text;

    // 1. 폴더 생성
    final createFolderRes = await http.post(
      Uri.parse('$baseUrl/api/v1/category'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'title': folderTitle,
      }),
    );

    if (createFolderRes.statusCode == 200 ||
        createFolderRes.statusCode == 201) {
      final decoded = json.decode(utf8.decode(createFolderRes.bodyBytes));
      final int categoryId = decoded is int
          ? decoded
          : (decoded is Map<String, dynamic> && decoded.containsKey('id'))
              ? decoded['id']
              : throw Exception("Unexpected response format: $decoded");

      // 2. 콘텐츠 저장
      final contentRes = await http.post(
        Uri.parse('$baseUrl/api/v1/content?category=$categoryId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': widget.contentTitle,
          'thumbnail': widget.thumbnail,
          'linkedUrl': widget.linkedUrl,
        }),
      );

      if (contentRes.statusCode == 200 || contentRes.statusCode == 201) {
        print("✅ 폴더 생성 후 콘텐츠 저장 완료");

        if (context.mounted) {
          Navigator.pop(context); // ✅ AddNewFolderSharedModal 닫기
          Navigator.pop(context); // ✅ SharedModal 닫기
        }
      } else {
        print("❌ 콘텐츠 저장 실패: ${contentRes.statusCode}");
      }
    } else {
      print("❌ 폴더 생성 실패: ${createFolderRes.statusCode}");
    }
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
            Text("새로운 폴더",
                style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'Six',
                    color: AppTheme.textColor)),
            const SizedBox(height: 2),
            Text("새 폴더 이름을 입력하고 콘텐츠를 저장할게요.",
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Four',
                    color: AppTheme.textColor)),
            const SizedBox(height: 8),
            SizedBox(
              width: 232,
              height: 26,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "제목",
                  hintStyle: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Four',
                      color: AppTheme.textColor),
                  contentPadding: const EdgeInsets.all(7),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppTheme.buttonColor,
                ),
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Four',
                    color: AppTheme.textColor),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 0.5, color: AppTheme.buttonDividerColor),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: Text("취소",
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'Four',
                              color: AppTheme.secondaryColor)),
                    ),
                  ),
                ),
                Container(
                    width: 0.5,
                    height: 42.5,
                    color: AppTheme.buttonDividerColor),
                Expanded(
                  child: InkWell(
                    onTap: isTextEntered ? createFolderAndSaveContent : null,
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
