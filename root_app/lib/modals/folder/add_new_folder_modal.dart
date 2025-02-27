import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:root_app/components/navbar.dart';
import 'package:root_app/screens/folder.dart';
import 'package:root_app/main.dart';
import 'package:root_app/styles/colors.dart';

class AddNewFolderModal extends StatefulWidget {
  final TextEditingController controller;
  final Function(Map<String, dynamic> newFolder)? onFolderAdded;

  const AddNewFolderModal({
    Key? key,
    required this.controller,
    this.onFolderAdded,
  }) : super(key: key);

  @override
  _AddNewFolderModalState createState() => _AddNewFolderModalState();
}

class _AddNewFolderModalState extends State<AddNewFolderModal> {
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

  // 지피티형 샤라웃 log 찍는거 도와주심

  Future<Map<String, dynamic>?> _createFolder() async {
    final String title = widget.controller.text;
    if (title.isEmpty) {
      //print('Folder name is empty');
      return null;
    }

    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      //print('BASE_URL is not defined in .env');
      return null;
    }

    final String url = '$baseUrl/api/v1/category';
    final Map<String, dynamic> requestBody = {
      'userId': userId,
      'title': title,
    };

    try {
      //print('Sending request to create folder...');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      //print('Response received: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final dynamic decodedResponse =
              json.decode(utf8.decode(response.bodyBytes));

          if (decodedResponse is Map<String, dynamic>) {
            //print('Folder created successfully: $decodedResponse');
            return decodedResponse;
          } else {
            //print('Unexpected response format: $decodedResponse');
            return null;
          }
        } catch (e) {
          //print('Response is not JSON: ${response.body}');
          return {'title': title};
        }
      } else {
        //print('Failed to create folder: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error creating folder: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: AppColors.primaryColor,
      child: Container(
        width: 270,
        height: 146,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
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
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  "새로운 폴더의 제목을 입력해주세요.",
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Four',
                    color: AppColors.textColor,
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
                        color: AppColors.textColor,
                      ),
                      contentPadding: const EdgeInsets.all(7),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.buttonColor,
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Four',
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            Divider(height: 0.5, color: AppColors.buttonDividerColor),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 42.5,
                      alignment: Alignment.center,
                      child: Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'Four',
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 42.5,
                  color: AppColors.buttonDividerColor,
                ),
                Expanded(
                  child: InkWell(
                    onTap: isTextEntered
                        ? () async {
                            //print('"저장" button clicked');
                            final newFolder = await _createFolder();

                            if (context.mounted) {
                              if (newFolder != null) {
                                //print('Navigating back to Folder inside NavBar');

                                // 모달 먼저 닫고고
                                Navigator.pop(context);

                                // 넵바도 같이 띄욱시시
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavBar(
                                      userId: userId,
                                      initialTab: 1, // folder.dart index
                                    ),
                                  ),
                                );
                              } else {
                                //print('Folder creation failed, but folder might exist.');
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
                              ? AppColors.secondaryColor
                              : AppColors.accentColor.withOpacity(0.5),
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
