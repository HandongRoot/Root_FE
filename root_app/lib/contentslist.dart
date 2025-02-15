import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/styles/colors.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:root_app/modals/rename_modal.dart';
import 'package:root_app/modals/delete_content_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart'; // To import global userId
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
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return;
    }
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

  Future<void> _deleteContent(Map<String, dynamic> content) async {
    final String contentId = content['id'].toString();
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return;
    }
    final String url = '$baseUrl/api/v1/content/$userId/$contentId';
    try {
      final response = await http.delete(Uri.parse(url));
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
    final RenderBox? icon =
        gridIconKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (icon != null) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final Offset iconPosition =
          icon.localToGlobal(Offset.zero, ancestor: overlay);

      final double menuWidth = 193.w;
      final double menuHeight = 108.h;

      final double top = iconPosition.dy + icon.size.height;
      double left = iconPosition.dx;

      if (left + menuWidth > MediaQuery.of(context).size.width) {
        left = MediaQuery.of(context).size.width - menuWidth - 32.w;
      } else if (left < 0) {
        left = 0;
      }

      final double right = MediaQuery.of(context).size.width - left - menuWidth;
      final RelativeRect position = RelativeRect.fromLTRB(
        left,
        top,
        right > 0 ? right : 0,
        MediaQuery.of(context).size.height - top - menuHeight,
      );

      showMenu<String>(
        context: context,
        position: position,
        items: <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'rename',
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "콘텐츠 제목 변경",
                  style: TextStyle(
                      color: Colors.black, fontSize: 12, fontFamily: 'Five'),
                ),
                SvgPicture.asset(IconPaths.rename),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1.0),
          PopupMenuItem<String>(
            value: 'changeCategory',
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "콘텐츠 위치 변경",
                  style: TextStyle(
                      color: Colors.black, fontSize: 12, fontFamily: 'Five'),
                ),
                SvgPicture.asset(IconPaths.move),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1.0),
          PopupMenuItem<String>(
            value: 'delete',
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "폴더에서 삭제",
                  style: TextStyle(
                      color: Colors.black, fontSize: 12, fontFamily: 'Five'),
                ),
                SvgPicture.asset(IconPaths.content_delete),
              ],
            ),
          ),
        ],
        color: Colors.white,
      ).then((value) {
        if (value == 'rename') {
          showDialog(
            context: context,
            builder: (context) => RenameModal(
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
        } else if (value == 'delete') {
          showDialog(
            context: context,
            builder: (context) => DeleteContentModal(
              content: content,
              onDelete: () async {
                await _deleteContent(content);
              },
            ),
          );
        }
      });
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 300.w,
          leading: Row(
            children: [
              SizedBox(width: 14.w),
              IconButton(
                icon: SvgPicture.asset(IconPaths.getIcon('back')),
                onPressed: () => Navigator.pushNamed(context, '/folder'),
              ),
              SizedBox(width: 14.w),
              SizedBox(
                width: 130.w,
                child: isEditingCategory
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
              ),
              SizedBox(width: 4),
              IconButton(
                icon: SvgPicture.asset(IconPaths.getIcon('pencil')),
                onPressed: () {
                  setState(() {
                    isEditingCategory = true;
                    _categoryController.text = currentCategory;
                  });
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (contents.isEmpty ? _buildNotFoundPage() : _buildGridView()),
      ),
    );
  }
}
