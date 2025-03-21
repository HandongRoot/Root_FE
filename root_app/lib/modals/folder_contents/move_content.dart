import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/modals/folder_contents/move_content_add_modal.dart';
import 'package:root_app/utils/content_change_util.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';
import 'package:root_app/utils/content_move_util.dart';

class MoveContent extends StatefulWidget {
  final Map<String, dynamic>? content;
  final Function(String)? onCategoryChanged;
  final List<Map<String, dynamic>>? contents;
  final VoidCallback? onMoveSuccess;

  const MoveContent({
    this.content,
    this.contents,
    this.onCategoryChanged,
    this.onMoveSuccess,
  });

  @override
  _MoveContentState createState() => _MoveContentState();
}

class _MoveContentState extends State<MoveContent> {
  List<Map<String, dynamic>> folders = [];
  Set<int> selectedContents = {};
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> loadFolders() async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return;
    }
    final String url = '$baseUrl/api/v1/category/findAll/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> foldersJson =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          folders = List<Map<String, dynamic>>.from(foldersJson);
        });
      } else {
        print('Failed to load folders, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error loading folders: $e");
    }
  }

  void _showToast(BuildContext context, String message, {Widget? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Container(
          width: 235,
          height: 50,
          padding: EdgeInsets.fromLTRB(17, 13, 17, 13),
          decoration: BoxDecoration(
            color: Color(0xFF393939),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  width: 20,
                  height: 20,
                  child: icon,
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFCFCFC),
                    fontSize: 14,
                    fontFamily: 'Five',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext modalContext) {
        double modalHeight = 606.h;
        return Container(
          width: MediaQuery.of(modalContext).size.width,
          height: modalHeight,
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // APP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(modalContext);
                    },
                    child: Text(
                      "취소",
                      style: TextStyle(
                        fontFamily: 'Four',
                        fontSize: 16,
                        color: Color(0xFF2960C6),
                      ),
                    ),
                  ),
                  Text(
                    "이동할 폴더 선택",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Five',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: modalContext,
                        builder: (context) => MoveContentAddNewFolderModal(
                          controller: _newCategoryController,
                          content: widget.content, // single content
                          contents: widget.contents, // multiple content
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      IconPaths.getIcon('add_folder'),
                    ),
                  ),
                ],
              ),
              // BODY
              Expanded(
                child: folders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 50,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final List<dynamic> contentList =
                              folder['contentReadDtos'] ?? [];
                          final recentTwoContents = contentList.toList();
                          return GestureDetector(
                            onTap: () async {
                              final String afterCategoryId =
                                  folder['id'].toString();

                              if (widget.contents != null &&
                                  widget.contents!.isNotEmpty) {
                                List<Map<String, dynamic>> contentsToMove = [];
                                for (var content in widget.contents!) {
                                  if (content['categoryId']?.toString() !=
                                      afterCategoryId) {
                                    contentsToMove.add(content);
                                  }
                                }
                                if (contentsToMove.isEmpty) {
                                  Navigator.pop(modalContext);
                                  _showToast(
                                      context, "선택한 콘텐츠 모두 이미 해당 폴더에 있습니다.");
                                  return;
                                }
                                bool success = await moveContentToFolder(
                                  contentsToMove
                                      .map((e) => e['id'].toString())
                                      .toList(),
                                  afterCategoryId,
                                );
                                if (success) {
                                  _showToast(
                                    context,
                                    "선택한 폴더로 이동되었습니다.",
                                    icon: SvgPicture.asset(
                                      IconPaths.getIcon('check'),
                                    ),
                                  );
                                  widget.onMoveSuccess?.call();
                                } else {
                                  _showToast(context, "콘텐츠 이동에 실패했습니다.");
                                }
                                Navigator.pop(modalContext);
                              } else if (widget.content != null) {
                                final String beforeCategoryId = widget
                                    .content!['categories']['id']
                                    .toString();
                                if (afterCategoryId == beforeCategoryId) {
                                  Navigator.pop(modalContext);
                                  _showToast(context, "콘텐츠 이동에 실패했습니다.");
                                  return;
                                }
                                bool success = await changeContentToFolder(
                                  [widget.content!['id'].toString()],
                                  beforeCategoryId,
                                  afterCategoryId,
                                );
                                if (success) {
                                  _showToast(
                                    context,
                                    "선택한 폴더로 이동되었습니다.",
                                    icon: SvgPicture.asset(
                                      IconPaths.getIcon('check'),
                                    ),
                                  );
                                  if (widget.onCategoryChanged != null) {
                                    widget.onCategoryChanged!(afterCategoryId);
                                  }
                                } else {
                                  _showToast(context, "콘텐츠 이동에 실패했습니다.");
                                }
                                Navigator.pop(modalContext);
                              }
                            },
                            child: _buildGridcontent(
                              folder: folder,
                              recentTwoContents: recentTwoContents,
                              isSelected: selectedContents.contains(index),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridcontent({
    required Map<String, dynamic> folder,
    required List<dynamic> recentTwoContents,
    required bool isSelected,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: SvgPicture.asset(
                'assets/folder.svg',
                width: 150,
                height: 136,
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: Container(
                padding: EdgeInsets.fromLTRB(12.5, 0, 12.5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (recentTwoContents.length == 1)
                      Spacer(flex: 1)
                    else
                      Spacer(flex: 6),
                    for (int i = 0; i < recentTwoContents.length; i++) ...[
                      AspectRatio(
                        aspectRatio: 2.72,
                        child: Container(
                          width: 125,
                          height: 46,
                          padding: EdgeInsets.all(6.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11.3.r),
                          ),
                          // CONTENTS
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.66.r),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        recentTwoContents[i]['thumbnail'] ?? '',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/placeholder.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  recentTwoContents[i]['title'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.31,
                                    fontFamily: 'Five',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.start,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                    ],
                    if (recentTwoContents.length == 1)
                      Spacer(flex: 2)
                    else
                      Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 149.91,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              Text(
                folder['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Six',
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              Text(
                "${folder['countContents'] ?? recentTwoContents.length}",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Four',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }
}
