import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:root_app/modals/add_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';
import 'package:root_app/utils/content_move_util.dart';

class ChangeModal extends StatefulWidget {
  final Map<String, dynamic>? item;
  final Function(String)? onCategoryChanged;
  final List<Map<String, dynamic>>? items;
  final VoidCallback? onMoveSuccess;

  const ChangeModal({
    this.item,
    this.items,
    this.onCategoryChanged,
    this.onMoveSuccess,
  });

  @override
  _ChangeModalState createState() => _ChangeModalState();
}

class _ChangeModalState extends State<ChangeModal> {
  List<Map<String, dynamic>> folders = [];
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadFolders();
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
        duration: Duration(seconds: 30),
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
              SvgPicture.asset(
                IconPaths.getIcon('check'),
              ),
              SizedBox(width: 10.w),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFCFCFC),
                  fontSize: 14,
                  fontFamily: 'Five',
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
                      // TODO 클백
                      showDialog(
                        context: modalContext,
                        builder: (context) => AddModal(
                          controller: TextEditingController(),
                          onSave: () async {
                            Navigator.of(context).pop();
                          },
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
                        padding: EdgeInsets.fromLTRB(0, 40.h, 0, 40.h),
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
                          final topItems = contentList.toList();
                          return GestureDetector(
                            onTap: () async {
                              final String selectedCategoryId =
                                  folder['id'].toString();

                              if (widget.items != null &&
                                  widget.items!.isNotEmpty) {
                                List<Map<String, dynamic>> itemsToMove = [];
                                for (var content in widget.items!) {
                                  if (content['categoryId']?.toString() !=
                                      selectedCategoryId) {
                                    itemsToMove.add(content);
                                  }
                                }
                                if (itemsToMove.isEmpty) {
                                  Navigator.pop(modalContext);
                                  _showToast(
                                      context, "선택한 콘텐츠 모두 이미 해당 폴더에 있습니다.");
                                  return;
                                }
                                bool success = await moveContentToFolder(
                                  itemsToMove
                                      .map((e) => e['id'].toString())
                                      .toList(),
                                  selectedCategoryId,
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
                              } else if (widget.item != null) {
                                final String currentCategoryId =
                                    widget.item!['categoryId'].toString();
                                if (selectedCategoryId == currentCategoryId) {
                                  Navigator.pop(modalContext);
                                  _showToast(context, "콘텐츠 이동에 실패했습니다.");
                                  return;
                                }
                                bool success = await moveContentToFolder(
                                  [widget.item!['id'].toString()],
                                  selectedCategoryId,
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
                                    widget
                                        .onCategoryChanged!(selectedCategoryId);
                                  }
                                } else {
                                  _showToast(context, "콘텐츠 이동에 실패했습니다.");
                                }
                                Navigator.pop(modalContext);
                              }
                            },
                            child: _buildGridItem(
                              folder: folder,
                              topItems: topItems,
                              isSelected: selectedItems.contains(index),
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

  Widget _buildGridItem({
    required Map<String, dynamic> folder,
    required List<dynamic> topItems,
    required bool isSelected,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                padding: EdgeInsets.fromLTRB(12.5, 28.h, 12.5, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < topItems.length; i++) ...[
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
                                    imageUrl: topItems[i]['thumbnail'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  topItems[i]['title'],
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
                  fontFamily: 'Four',
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              Text(
                "${folder['countContents'] ?? topItems.length}",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Two',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
