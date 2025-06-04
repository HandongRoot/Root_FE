import 'package:flutter/material.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';
import 'package:get/get.dart';
import 'package:root_app/controllers/folder_controller.dart';

class AddNewFolderAndSaveModal extends StatefulWidget {
  final String contentTitle;
  final String thumbnail;
  final String linkedUrl;

  const AddNewFolderAndSaveModal({
    super.key,
    required this.contentTitle,
    required this.thumbnail,
    required this.linkedUrl,
  });

  @override
  State<AddNewFolderAndSaveModal> createState() =>
      _AddNewFolderAndSaveModalState();
}

class _AddNewFolderAndSaveModalState extends State<AddNewFolderAndSaveModal> {
  final TextEditingController controller = TextEditingController();
  final folderController = Get.find<FolderController>();

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
    final success = await ApiService.createFolderAndSaveContent(
      folderTitle: controller.text,
      contentTitle: widget.contentTitle,
      thumbnail: widget.thumbnail,
      linkedUrl: widget.linkedUrl,
    );

    if (success && context.mounted) {
      Navigator.pop(context); // 닫기 1
      Navigator.pop(context); // 닫기 2
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
