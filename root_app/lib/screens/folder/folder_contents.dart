import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/modals/folder_contents/move_content.dart';
import 'package:root_app/modals/folder_contents/remove_content_modal.dart';
import 'package:root_app/modals/rename_content_modal.dart';
import 'package:root_app/screens/folder/contents_tutorial.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/utils/icon_paths.dart';

class FolderContents extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Function(String, String)? onContentRenamed;
  final Function(String)? onContentDeleted;

  const FolderContents({
    required this.categoryId,
    required this.categoryName,
    this.onContentRenamed,
    this.onContentDeleted,
  });

  @override
  _FolderContentsState createState() => _FolderContentsState();
}

class _FolderContentsState extends State<FolderContents> {
  final ScrollController _scrollController = ScrollController();
  final folderController = Get.find<FolderController>();

  double _scrollBarPosition = 0.0;
  Timer? _scrollBarTimer;
  bool _showScrollBar = true;
  double get _maxScrollBarHeight => MediaQuery.of(context).size.height * 0.8;

  List<dynamic> contents = [];
  bool isLoadingMore = false; // 🔄 스크롤 추가 로딩 중 여부
  bool hasMore = true; // ✅ 더 불러올 콘텐츠가 있는지 여부
  List<GlobalKey> gridIconKeys = [];
  bool isLoading = true;

  bool isEditingCategory = false;
  late TextEditingController _categoryController;
  late String currentCategory;
  late FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _showTutorialIfNeeded();
    currentCategory = widget.categoryName;
    _categoryController = TextEditingController(text: currentCategory);
    loadContentsByCategory(); // ✅ 새 함수로 변경
    _scrollController.addListener(_onScroll);
  }

  Future<void> _showTutorialIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTimeFolder = prefs.getBool('isFirstTimeFolder') ?? true;

    if (isFirstTimeFolder) {
      await prefs.setBool('isFirstTimeFolder', false); // 딱핸번만

      Get.dialog(ContentsTutorial(), barrierColor: Colors.transparent);
    }
  }

  Future<void> loadContentsByCategory({bool loadMore = false}) async {
    if (isLoadingMore ||
        (!loadMore && isLoading == false && contents.isNotEmpty)) return;
    // 이미 로딩 중이거나, 불필요한 중복 호출 방지

    if (!loadMore) {
      setState(() {
        isLoading = true;
      });
    }
    isLoadingMore = true;

    try {
      String? lastContentId;
      if (loadMore && contents.isNotEmpty) {
        lastContentId = contents.last['id'].toString();
      }

      final newContents = await ApiService.getFolderPaginatedContents(
        widget.categoryId,
        contentId: lastContentId,
      );

      setState(() {
        if (loadMore) {
          contents.addAll(newContents);
          gridIconKeys.addAll(
              List.generate(newContents.length, (index) => GlobalKey()));
        } else {
          contents = newContents;
          gridIconKeys =
              List.generate(newContents.length, (index) => GlobalKey());
        }

        hasMore = newContents.isNotEmpty;
      });
    } catch (e) {
      print("❌ 콘텐츠 로딩 중 오류: $e");
    } finally {
      if (!loadMore) {
        setState(() {
          isLoading = false;
        });
      }
      isLoadingMore = false;
    }
  }

  void _onScroll() {
    if (!mounted || contents.isEmpty) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      loadContentsByCategory(loadMore: true);
    }

    final scrollFraction =
        _scrollController.offset / _scrollController.position.maxScrollExtent;

    setState(() {
      _scrollBarPosition = scrollFraction * _maxScrollBarHeight;
      _showScrollBar = true;
    });

    _scrollBarTimer?.cancel();
    _scrollBarTimer = Timer(Duration(seconds: 2), () {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showScrollBar = false;
          });
        }
      });
    });
  }

  Future<void> _renameContent(
      Map<String, dynamic> content, String newTitle) async {
    bool success =
        await ApiService.renameContent(content['id'].toString(), newTitle);
    if (success) {
      setState(() {
        content['title'] = newTitle;
      });
      widget.onContentRenamed?.call(content['id'].toString(), newTitle);
      folderController.loadFolders();
    }
  }

  Future<void> _removeContent(Map<String, dynamic> content) async {
    bool success = await ApiService.removeContent(
        content['id'].toString(), content['categories']['id'].toString());
    if (success) {
      setState(() {
        contents.remove(content);
      });
      widget.onContentDeleted?.call(content['id'].toString());
      folderController.loadFolders();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _scrollController.dispose();
    _scrollBarTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildNotFoundPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              IconPaths.getIcon('notfound_folder'),
            ),
            SizedBox(height: 20.h),
            Text(
              "아직 저장된 콘텐츠가 없어요\n관심 있는 콘텐츠를 저장하고 빠르게 찾아보세요!",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontFamily: 'Five',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding:
          EdgeInsets.only(left: 20.w, top: 10.h, right: 20.w, bottom: 20.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double mincontentWidth = 165.0;
          int crossAxisCount = (constraints.maxWidth / mincontentWidth).floor();
          crossAxisCount = crossAxisCount.clamp(2, 6);
          return GridView.builder(
            controller: _scrollController, // ✅ 이 줄 추가
            itemCount: contents.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20.w,
              mainAxisSpacing: 20.h,
            ),
            itemBuilder: (context, index) {
              final content = contents[index];
              return _buildGridcontentTile(content, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildGridcontentTile(Map<String, dynamic> content, int index) {
    return InkWell(
      onTap: () async {
        final String? linkedUrl = content['linkedUrl'];
        if (linkedUrl != null && linkedUrl.isNotEmpty) {
          final Uri uri = Uri.parse(linkedUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to open link")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid URL")),
          );
        }
      },
      child: SizedBox(
        height: 165,
        width: 165,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: content['thumbnail'] ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: IconButton(
                key: gridIconKeys.length > index
                    ? gridIconKeys[index]
                    : GlobalKey(),
                onPressed: () => _showOptionsModal(context, content, index),
                icon: SvgPicture.asset(IconPaths.getIcon('hamburger')),
                padding: EdgeInsets.all(11.r),
                constraints: const BoxConstraints(),
              ),
            ),
            Positioned(
              bottom: 15.h,
              left: 11.w,
              right: 11.w,
              child: Text(
                content['title'] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Five',
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsModal(
      BuildContext context, Map<String, dynamic> content, int index) {
    final RenderBox? iconBox =
        gridIconKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (iconBox != null) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final Offset iconPosition =
          iconBox.localToGlobal(Offset.zero, ancestor: overlay);
      final double screenWidth = MediaQuery.of(context).size.width;
      final double menuWidth = 193;
      final double menuHeight = 90;

      const double minContentWidth = 165.0;
      int crossAxisCount = (screenWidth / minContentWidth).floor().clamp(2, 6);

      int columnIndex = index % crossAxisCount;
      double left = iconPosition.dx;

      if (columnIndex == crossAxisCount - 1 || left + menuWidth > screenWidth) {
        left = screenWidth - menuWidth - 16.w;
      }

      final RelativeRect position = RelativeRect.fromLTRB(
        left,
        iconPosition.dy + iconBox.size.height,
        screenWidth - left - menuWidth,
        MediaQuery.of(context).size.height - (iconPosition.dy + menuHeight),
      );

      showMenu<String>(
        context: context,
        position: position,
        items: [
          PopupMenuItem<String>(
            value: 'rename',
            height: 36,
            child: Container(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: _buildMenuItem("콘텐츠 제목 변경", IconPaths.rename),
            ),
          ),
          PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'changeCategory',
            height: 36,
            child: Container(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: _buildMenuItem("콘텐츠 위치 변경", IconPaths.move),
            ),
          ),
          PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'remove',
            height: 36,
            child: Container(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: _buildMenuItem("폴더에서 삭제", IconPaths.content_delete,
                  textColor: Color(0xFFFF2828)),
            ),
          ),
        ],
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.25),
        elevation: 5,
      ).then((value) {
        _handleMenuSelection(context, value, content);
      });
    }
  }

  Widget _buildMenuItem(String text, String iconPath, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Five',
            color: textColor ?? Color(0xFF393939),
          ),
        ),
        SvgPicture.asset(
          iconPath,
          width: 16,
          height: 16,
        ),
      ],
    );
  }

  void _handleMenuSelection(
      BuildContext context, String? value, Map<String, dynamic> content) {
    if (value == 'rename') {
      showDialog(
        context: context,
        builder: (context) => RenameContentModal(
          initialTitle: content['title'],
          onSave: (newTitle) async {
            await _renameContent(content, newTitle);
          },
        ),
      );
    } else if (value == 'changeCategory') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: MoveContent(
            content: content,
            onCategoryChanged: (newCategoryId) {
              setState(() {
                contents.removeWhere((element) =>
                    element['id'].toString() == content['id'].toString());
              });
              folderController.loadFolders();
            },
          ),
        ),
      );
    } else if (value == 'remove') {
      showDialog(
        context: context,
        builder: (context) => RemoveContent(
          content: content,
          onDelete: () async {
            await _removeContent(content);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Get.offAndToNamed('/folder');

          Get.to(() => NavBar(
                initialTab: 1,
              ));
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: SvgPicture.asset(IconPaths.getIcon('back')),
            onPressed: () {
              Get.offAndToNamed('/folder');
              Get.offAll(() => NavBar(initialTab: 1));
            },
          ),
          title: isEditingCategory
              ? Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _categoryController,
                    focusNode: _focusNode,
                    autofocus: true, // 키보드 올라오게
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Five',
                      height: 1.0,
                    ),
                    selectionControls: MaterialTextSelectionControls(),
                    decoration: InputDecoration(
                      border: InputBorder.none, // 무슨 밑에 선? 빼기
                      isDense: true, //추가padding뺴기
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
              : GestureDetector(
                  onLongPress: () {
                    setState(() {
                      isEditingCategory = true;
                      _categoryController.text = currentCategory;
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      currentCategory,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Five',
                          height: 1.0),
                      enableInteractiveSelection: true,
                      contextMenuBuilder:
                          (BuildContext context, EditableTextState state) {
                        return AdaptiveTextSelectionToolbar.editableText(
                          editableTextState: state,
                        );
                      },
                    ),
                  )),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: isEditingCategory
                  ? TextButton(
                      onPressed: () async {
                        final newName = _categoryController.text.trim();
                        if (newName.isNotEmpty && newName != currentCategory) {
                          final success = await ApiService.updateFolderName(
                              widget.categoryId, newName);
                          if (success) {
                            setState(() {
                              currentCategory = newName;
                              isEditingCategory = false;
                            });
                            folderController.loadFolders();
                          }
                        } else {
                          setState(() {
                            isEditingCategory = false;
                          });
                        }
                      },
                      child: Text(
                        "완료",
                        style: TextStyle(
                          color: Color.fromRGBO(41, 96, 198, 1.0),
                          fontSize: 13,
                          fontFamily: 'Five',
                        ),
                      ),
                    )
                  : IconButton(
                      icon: SvgPicture.asset(IconPaths.getIcon('pencil')),
                      onPressed: () {
                        setState(() {
                          isEditingCategory = true;
                          _categoryController.text = currentCategory;
                        });
                      },
                    ),
            ),
          ],
        ),
        body: Stack(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : (contents.isEmpty ? _buildNotFoundPage() : _buildGridView()),
            if (_scrollController.hasClients &&
                _scrollController.position.maxScrollExtent > 0 &&
                _showScrollBar)
              Positioned(
                right: -10,
                top: 10,
                bottom: 10,
                child: AnimatedOpacity(
                  opacity: _showScrollBar ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _scrollBarPosition += details.delta.dy;
                        _scrollBarPosition =
                            _scrollBarPosition.clamp(0, _maxScrollBarHeight);
                        final scrollFraction =
                            _scrollBarPosition / _maxScrollBarHeight;
                        _scrollController.jumpTo(
                          scrollFraction *
                              _scrollController.position.maxScrollExtent,
                        );
                      });
                    },
                    child: SizedBox(
                      width: 48.w,
                      height: _maxScrollBarHeight,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: _scrollBarPosition,
                            child: IconButton(
                              icon: SvgPicture.asset('assets/scroll.svg'),
                              onPressed: () {},
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
