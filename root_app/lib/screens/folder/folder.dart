import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/modals/folder/delete_folder_modal.dart';
import 'package:root_app/modals/folder/add_new_folder_modal.dart';
import 'package:root_app/screens/folder/folder_contents.dart';
import 'package:root_app/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'folder_appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Folder extends StatefulWidget {
  final Function(bool)? onScrollDirectionChange;
  final Function(bool)? onEditModeChange;

  const Folder({
    Key? key,
    required this.onScrollDirectionChange,
    this.onEditModeChange,
  }) : super(key: key);

  @override
  State<Folder> createState() => FolderState();
}

class FolderState extends State<Folder> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool get isEditingMode => isEditing;

  final FolderController folderController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newCategoryController = TextEditingController();
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
    await showDialog<Map<String, dynamic>>(
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
      child: SizedBox(
        width: 159,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: SvgPicture.asset(
                'assets/addfolder.svg',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
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
    super.build(context);
    return Scaffold(
      appBar: FolderAppBar(
        isEditing: isEditing,
        onToggleEditing: _toggleEditMode,
        onEditingModeChanged: (bool editing) {
          widget.onEditModeChange?.call(editing);
        },
      ),
      body: Obx(() {
        if (folderController.isLoadingFolders.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.secondaryColor,
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.secondaryColor,
          backgroundColor: Colors.white,
          onRefresh: loadFolders,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: folderController.folders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAddFolderButton(),
                            SizedBox(height: 6.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: ClipPath(
                                    clipper: SimpleTriangleClipper(),
                                    child: Container(
                                      width: 14,
                                      height: 8,
                                      color: const Color(0xFFEFF3FF),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF3FF),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '콘텐츠를 분류하여 보관할 새 폴더를 만들어보세요!',
                                    style: TextStyle(
                                      color: const Color(0xFF2960C6),
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
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 86.h),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 32,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: folderController.folders.length + 1,
                    itemBuilder: (context, index) {
                      if (index == folderController.folders.length) {
                        return isEditing
                            ? const SizedBox.shrink()
                            : _buildAddFolderButton();
                      }

                      final folder = folderController.folders[index];
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
                        recentTwoContents:
                            List<Map<String, dynamic>>.from(recentTwoContents),
                        totalCount: totalCount,
                        isEditing: isEditing,
                        onDelete: () async {
                          await _deleteCategoryModal(folderId);
                        },
                        onPressed: () {
                          if (!isEditing) {
                            Get.to(
                              () => FolderContents(
                                categoryId: folderId,
                                categoryName: folderTitle,
                                onContentRenamed: (contentId, newTitle) {
                                  setState(() {
                                    final folderIndex = folderController.folders
                                        .indexWhere((folder) =>
                                            folder['id'].toString() ==
                                            folderId);
                                    if (folderIndex != -1) {
                                      List<dynamic> contentList =
                                          folderController.folders[folderIndex]
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
                                    final folderIndex = folderController.folders
                                        .indexWhere((folder) =>
                                            folder['id'].toString() ==
                                            folderId);
                                    if (folderIndex != -1) {
                                      List<dynamic> contentList =
                                          folderController.folders[folderIndex]
                                                  ['contentReadDtos'] ??
                                              [];
                                      contentList.removeWhere((content) =>
                                          content['id'].toString() ==
                                          contentId);
                                    }
                                  });
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        );
      }),
    );
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteFolderModal(
                          category: category,
                          onDelete: onDelete ?? () => Get.back(),
                        ),
                      );
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        IconPaths.getIcon('folder_delete'),
                        width: 25.w,
                        height: 25.h,
                      ),
                    ),
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
