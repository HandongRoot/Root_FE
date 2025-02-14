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

@override
  Widget build(BuildContext context) {
    // Builder를 사용해서 modal 전용 context를 획득합니다.
    return Builder(
      builder: (BuildContext modalContext) {
        double modalHeight = 0.7.sh;
        if (modalHeight > 606.h) {
          modalHeight = 606.h;
        }
        return Container(
          color: Colors.white,
          height: modalHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(modalContext); // 모달만 닫힘
                    },
                    child: Text(
                      "취소",
                      style: TextStyle(fontSize: 16.sp, color: Colors.black),
                    ),
                  ),
                  Text(
                    "이동할 폴더 선택",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: 'Four',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      print('add_folder 버튼 클릭됨');
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
              SizedBox(height: 20.h),
              Expanded(
                child: folders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.w,
                          mainAxisSpacing: 20.h,
                        ),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final List<dynamic> contentList =
                              folder['contentReadDtos'] ?? [];
                          final topItems = contentList.take(2).toList();
                          return GestureDetector(
                            onTap: () async {
                              final String selectedCategoryId = folder['id'].toString();

                              // 다중 선택 모드: widget.items가 null이 아니면 여러 콘텐츠 이동
                              if (widget.items != null && widget.items!.isNotEmpty) {
                                List<Map<String, dynamic>> itemsToMove = [];
                                for (var content in widget.items!) {
                                  // 콘텐츠의 현재 폴더는 content['categoryId']
                                  if (content['categoryId']?.toString() != selectedCategoryId) {
                                    itemsToMove.add(content);
                                  }
                                }
                                if (itemsToMove.isEmpty) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("선택한 콘텐츠 모두 이미 해당 폴더에 있습니다.")),
                                  );
                                  return;
                                }
                                bool success = await moveContentToFolder(
                                  itemsToMove.map((e) => e['id'].toString()).toList(),
                                  selectedCategoryId,
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("콘텐츠 이동에 성공했습니다.")),
                                  );
                                  widget.onMoveSuccess?.call();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("콘텐츠 이동에 실패했습니다.")),
                                  );
                                }
                                Navigator.pop(modalContext);
                              } else if (widget.item != null) {
                                // 단일 콘텐츠 이동 모드
                                final String currentCategoryId = widget.item!['categoryId'].toString();
                                if (selectedCategoryId == currentCategoryId) {
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("콘텐츠 이동에 실패했습니다.")),
                                  );
                                  return;
                                }
                                bool success = await moveContentToFolder(
                                  [widget.item!['id'].toString()],
                                  selectedCategoryId,
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("콘텐츠 이동에 성공했습니다.")),
                                  );
                                  if (widget.onCategoryChanged != null) {
                                    widget.onCategoryChanged!(selectedCategoryId);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("콘텐츠 이동에 실패했습니다.")),
                                  );
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
    return Container(
      width: 165.w,
      height: 210.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SvgPicture.asset(
                    'assets/modal_folder.svg',
                    width: 165.w,
                    height: 130.h,
                    fit: BoxFit.contain,
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 6.h),
                        for (int i = 0; i < topItems.length; i++) ...[
                          Container(
                            width: 145.w,
                            padding: EdgeInsets.all(6.r),
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: CachedNetworkImage(
                                    imageUrl: topItems[i]['thumbnail'],
                                    width: 30.w,
                                    height: 30.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    topItems[i]['title'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                      fontFamily: 'Four',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                folder['title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Five',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              Text(
                "${folder['countContents'] ?? topItems.length} items",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          if (isSelected)
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
