// move_content 에서 새로 추가 할떄 뜨는 모달
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/services/content_service.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:root_app/utils/toast_util.dart';

class MoveContentAddNewFolderModal extends StatefulWidget {
  final TextEditingController controller;
  final Map<String, dynamic>? content;
  final List<Map<String, dynamic>>? contents;
  final folderController = Get.find<FolderController>();

  MoveContentAddNewFolderModal({
    super.key,
    required this.controller,
    this.content,
    this.contents,
  });

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

  Future<String?> _createFolder() async {
    final String title = widget.controller.text;
    if (title.isEmpty) return null;

    final result = await ApiService.createFolder(title);
    return result?['id']?.toString();
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
                            final newCategoryId = await _createFolder();
                            if (newCategoryId == null) return;

                            final List<String> contentIds = [];
                            if (widget.content != null) {
                              contentIds.add(widget.content!['id'].toString());
                            } else if (widget.contents != null &&
                                widget.contents!.isNotEmpty) {
                              contentIds.addAll(widget.contents!
                                  .map((c) => c['id'].toString()));
                            }

                            if (contentIds.isEmpty) {
                              ToastUtil.showToast(context, "이동할 콘텐츠가 없습니다.");
                              return;
                            }

                            final success =
                                await ContentService.moveContentToFolder(
                                    contentIds, newCategoryId);

                            if (success) {
                              widget.folderController.loadFolders();
                              ToastUtil.showToast(
                                context,
                                "새 폴더로 이동 완료!",
                                icon: SvgPicture.asset(
                                    IconPaths.getIcon('check')),
                              );
                              Get.back();
                              Get.back();
                            } else {
                              ToastUtil.showToast(context, "콘텐츠 이동에 실패했습니다.");
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
