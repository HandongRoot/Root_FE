import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/modals/contentListPage/change_modal.dart';
import 'package:root_app/modals/contentListPage/remove_content_from_category.dart';
import 'package:root_app/modals/rename_content_modal.dart';
import 'package:root_app/styles/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';
import 'utils/icon_paths.dart';

class ContentsList extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Function(String, String)? onContentRenamed;
  final Function(String)? onContentDeleted;

  const ContentsList({
    required this.categoryId,
    required this.categoryName,
    this.onContentRenamed,
    this.onContentDeleted,
  });

  @override
  _ContentsListState createState() => _ContentsListState();
}

class _ContentsListState extends State<ContentsList> {
  List<dynamic> contents = [];
  List<GlobalKey> gridIconKeys = [];
  bool isLoading = true;

  bool isEditingCategory = false;
  late TextEditingController _categoryController;
  late String currentCategory;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.categoryName;
    _categoryController = TextEditingController(text: currentCategory);
    loadcontentsByCategory();
  }

  Future<void> loadcontentsByCategory() async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String url =
        '$baseUrl/api/v1/content/find/$userId/${widget.categoryId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          contents = data;
          gridIconKeys = List.generate(contents.length, (index) => GlobalKey());
        });
      } else {
        print('Failed to load contents, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error loading items: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _renameContent(
      Map<String, dynamic> content, String newTitle) async {
    final String contentId = content['id'].toString();
    final String? baseUrl = dotenv.env['BASE_URL'];
    final String url =
        '$baseUrl/api/v1/content/update/title/$userId/$contentId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': newTitle}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          content['title'] = newTitle;
        });
        if (widget.onContentRenamed != null) {
          widget.onContentRenamed!(contentId, newTitle);
        }
      } else {
        print('Rename failed, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error renaming content: $e');
    }
  }

  Future<void> _removeContent(Map<String, dynamic> content) async {
    final String contentId = content['id'].toString();
    final String beforeCategoryId = content['categories']['id'].toString();
    final String afterCategoryId = "0";

    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return;
    }

    final String url =
        '$baseUrl/api/v1/content/change/$userId/$beforeCategoryId/$afterCategoryId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(contentId),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          contents.remove(content);
        });
        if (widget.onContentDeleted != null) {
          widget.onContentDeleted!(contentId);
        }
      } else {
        print('Deletion failed, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting content: $e');
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
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
          child: ChangeModal(
            content: content,
            onCategoryChanged: (newCategoryId) {
              setState(() {
                contents.removeWhere((element) =>
                    element['id'].toString() == content['id'].toString());
              });
            },
          ),
        ),
      );
    } else if (value == 'remove') {
      showDialog(
        context: context,
        builder: (context) => RemoveContentFromCategoryModal(
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: SvgPicture.asset(IconPaths.getIcon('back')),
            onPressed: () => Navigator.pop(context),
          ),
          title: isEditingCategory
              ? TextField(
                  controller: _categoryController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Five',
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      currentCategory = value;
                      isEditingCategory = false;
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  currentCategory,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Five',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: IconButton(
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (contents.isEmpty ? _buildNotFoundPage() : _buildGridView()),
      ),
    );
  }
}
