import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/modals/folder/delete_folder_modal.dart';
import 'package:root_app/modals/folder/add_new_folder_modal.dart';
import 'package:root_app/screens/folder/folder_contents.dart';
import 'package:root_app/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'folder_appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Folder extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;
  const Folder({Key? key, required this.onScrollDirectionChange})
      : super(key: key);

  @override
  FolderState createState() => FolderState();
}

class FolderState extends State<Folder> {
  final FolderController folderController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newCategoryController = TextEditingController();
  double _previousOffset = 0.0;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (folderController.folders.isEmpty) {
        folderController.loadFolders();
      }
    });
  }

// navbar
  void refreshFolders() {
    loadFolders();
  }

  Future<void> loadFolders() async {
    await folderController.loadFolders();
  }

  Future<void> _deleteCategoryModal(String folderId) async {
    bool success = await ApiService.deleteFolder(folderId);
    if (success) {
      setState(() {
        folderController.folders
            .removeWhere((folder) => folder['id'].toString() == folderId);
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset > _previousOffset) {
      widget.onScrollDirectionChange(false);
    } else {
      widget.onScrollDirectionChange(true);
    }
    _previousOffset = _scrollController.offset;
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _refreshAfterDelay() async {
    await Future.delayed(Duration(seconds: 1));
    await folderController.loadFolders();
  }

  Future<void> _showAddCategoryModal() async {
    final newFolder = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddNewFolderModal(
          controller: _newCategoryController,
          onFolderAdded: (folder) {
            setState(() {
              folderController.folders.add(folder);
            });
            _refreshAfterDelay();
          },
        );
      },
    );
  }

  Widget _buildAddFolderButton() {
    return GestureDetector(
      onTap: _showAddCategoryModal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.1,
            child: SvgPicture.asset(
              'assets/addfolder.svg',
              width: 159,
              height: 144,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FolderAppBar(
          isEditing: isEditing,
          onToggleEditing: _toggleEditMode,
        ),
        body: RefreshIndicator(
          onRefresh: loadFolders,
          child: Stack(
            children: [
              folderController.folders.isEmpty
                  ? ListView(
                      // RefreshIndicator needs a scrollable child
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        GestureDetector(
                          onTap: _showAddCategoryModal,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 12.h, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/addfolder.svg',
                                  width: 159,
                                  height: 144,
                                ),
                                SizedBox(height: 6.h),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 세모
                                    Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: ClipPath(
                                        clipper: SimpleTriangleClipper(),
                                        child: Container(
                                          width: 14,
                                          height: 8,
                                          color: Color(0xFFEFF3FF),
                                        ),
                                      ),
                                    ),

                                    // bubble 뭐시기
                                    Container(
                                      //margin: EdgeInsets.only(top: 2.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEFF3FF),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        '콘텐츠를 분류하여 보관할 새 폴더를 만들어보세요!',
                                        style: TextStyle(
                                          color: Color(0xFF2960C6),
                                          fontSize: 12.sp,
                                          fontFamily: 'Six',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 86.h),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 160,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 32,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: folderController.folders.isEmpty
                          ? 1
                          : folderController.folders.length + 1,
                      itemBuilder: (context, index) {
                        // Add Folder button at the END if folderController.folders exist
                        if (folderController.folders.isNotEmpty &&
                            index == folderController.folders.length) {
                          return _buildAddFolderButton();
                        }

// Add Folder button as FIRST if no folderController.folders exist
                        if (folderController.folders.isEmpty && index == 0) {
                          return _buildAddFolderButton();
                        }

                        // 🔹 Get the actual folder item (adjust index because index 0 is now "add folder")
                        final folder = folderController
                            .folders[index]; // ← no -1 here anymore
                        final folderTitle = folder['title'];
                        final folderId = folder['id'].toString();
                        final List<dynamic> contentList =
                            folder['contentReadDtos'] ?? [];
                        final recentTwoContents = contentList.toList();
                        final int totalCount =
                            folder['countContents'] ?? contentList.length;

                        return FolderWidget(
                          category: folderTitle,
                          folderId: folderId,
                          recentTwoContents: List<Map<String, dynamic>>.from(
                              recentTwoContents),
                          totalCount: totalCount,
                          isEditing: isEditing,
                          onDelete: () async {
                            await _deleteCategoryModal(folderId);
                          },
                          onPressed: () {
                            if (!isEditing) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FolderContents(
                                    categoryId: folderId,
                                    categoryName: folderTitle,
                                    onContentRenamed: (contentId, newTitle) {
                                      setState(() {
                                        final folderIndex = folderController
                                            .folders
                                            .indexWhere((folder) =>
                                                folder['id'].toString() ==
                                                folderId);
                                        if (folderIndex != -1) {
                                          List<dynamic> contentList =
                                              folderController
                                                          .folders[folderIndex]
                                                      ['contentReadDtos'] ??
                                                  [];
                                          for (var content in contentList) {
                                            if (content['id'].toString() ==
                                                contentId) {
                                              content['title'] = newTitle;
                                              break;
                                            }
                                          }
                                        }
                                      });
                                    },
                                    onContentDeleted: (contentId) {
                                      setState(() {
                                        final folderIndex = folderController
                                            .folders
                                            .indexWhere((folder) =>
                                                folder['id'].toString() ==
                                                folderId);
                                        if (folderIndex != -1) {
                                          List<dynamic> contentList =
                                              folderController
                                                          .folders[folderIndex]
                                                      ['contentReadDtos'] ??
                                                  [];
                                          contentList.removeWhere((content) =>
                                              content['id'].toString() ==
                                              contentId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ],
          ),
        ));
  }
}

class SimpleTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class FolderWidget extends StatelessWidget {
  final String category;
  final String folderId;
  final List<Map<String, dynamic>> recentTwoContents;
  final int totalCount;
  final VoidCallback onPressed;
  final VoidCallback? onDelete;
  final bool isEditing;

  const FolderWidget({
    super.key,
    required this.category,
    required this.folderId,
    required this.recentTwoContents,
    required this.totalCount,
    required this.onPressed,
    this.onDelete,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: SvgPicture.asset(
                  'assets/folder.svg',
                  width: 159,
                  height: 144,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.fromLTRB(13, 0, 13, 5),
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
                          aspectRatio: 2.71,
                          child: Container(
                            width: 133,
                            height: 49,
                            padding: EdgeInsets.all(6.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: CachedNetworkImage(
                                      imageUrl: recentTwoContents[i]
                                              ['thumbnail'] ??
                                          '',
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    recentTwoContents[i]['title'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Three',
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
                        SizedBox(height: 6.h),
                      ],
                      if (recentTwoContents.length == 1)
                        Spacer(flex: 2)
                      else
                        Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
              if (isEditing)
                Positioned(
                  top: -20,
                  left: -20,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      IconPaths.getIcon('folder_delete'),
                      width: 25.w,
                      height: 25.h,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteFolderModal(
                          category: category,
                          onDelete:
                              onDelete ?? () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
            ],
          ),
          SizedBox(
            width: 159,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.h),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Four',
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  "$totalCount",
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
      ),
    );
  }
}
