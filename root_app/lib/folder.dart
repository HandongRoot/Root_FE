import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:root_app/modals/delete_modal.dart';
import 'components/folder_appbar.dart';
import 'modals/add_modal.dart';
import 'contentslist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'utils/icon_paths.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';

class Folder extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;

  const Folder({super.key, required this.onScrollDirectionChange});

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  Map<String, List<Map<String, dynamic>>> categorizedItems = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newCategoryController = TextEditingController();
  double _previousOffset = 0.0;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadFolderData();
  }

  Future<void> loadFolderData() async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('BASE_URL is not defined in .env');
      return;
    }
    final String url = '$baseUrl/api/v1/category/findAll/$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> foldersJson = json.decode(utf8.decode(response.bodyBytes));

        Map<String, List<Map<String, dynamic>>> fetchedFolders = {};
        for (var folder in foldersJson) {
          final String title = folder['title'];
          final List<dynamic> contentList = folder['contentReadDtos'] ?? [];

          fetchedFolders[title] = List<Map<String, dynamic>>.from(contentList.map((item) => item));
        }
        setState(() {
          categorizedItems = fetchedFolders;
        });
      } else {
        print('Failed to load folders, Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error loading folders: $e");
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

  void _confirmDeleteCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => DeleteModal(
        category: category,
        onDelete: () {
          setState(() {
            categorizedItems.remove(category);
          });
        },
      ),
    );
  }

  void _showAddCategoryModal() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddModal(
          controller: _newCategoryController,
          onSave: () async {
            final String title = _newCategoryController.text;
            if (title.isNotEmpty) {
              setState(() {
                categorizedItems[title] = [];
              });
              _newCategoryController.clear();
              final String? baseUrl = dotenv.env['BASE_URL'];
              if (baseUrl == null || baseUrl.isEmpty) {
                print('BASE_URL is not defined in .env');

                setState(() {
                  categorizedItems.remove(title);
                });
                return;
              }
              final String url = '$baseUrl/api/v1/category';
              final Map<String, dynamic> requestBody = {
                'userId': userId,
                'title': title,
              };
              try {
                final response = await http.post(
                  Uri.parse(url),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(requestBody),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  final Map<String, dynamic> folderResponse = json.decode(utf8.decode(response.bodyBytes));
                  setState(() {
                    // 새로 생성된 폴더를 categorizedItems에 추가
                    categorizedItems.remove(title);
                    categorizedItems[folderResponse['title']] =
                        List<Map<String, dynamic>>.from(folderResponse['contentReadDtos'] ?? []);
                  });
                  _newCategoryController.clear();
                } else {
                  setState(() {
                    categorizedItems.remove(title);
                  });
                  print('Failed to create folder: ${response.statusCode}');
                }
              } catch (e) {
                print('Error creating folder: $e');
              }
            }
          },
        );
      },
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
      body: Stack(
        children: [
          categorizedItems.isEmpty
              ? const Center(child: LinearProgressIndicator())
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 86.h),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 203,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 32,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: categorizedItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == categorizedItems.length) {
                      return GestureDetector(
                        onTap: _showAddCategoryModal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 12.h),
                            AspectRatio(
                              aspectRatio: 1.1,
                              child: SvgPicture.asset(
                                'assets/addfolder.svg',
                                width: 159.w,
                                height: 144.h,
                                fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                    final category = categorizedItems.keys.elementAt(index);
                    final topItems =
                        categorizedItems[category]!.take(2).toList();

                    return FolderWidget(
                      category: category,
                      topItems: topItems,
                      isEditing: isEditing,
                      onDelete: () => _confirmDeleteCategory(category),
                      onPressed: () {
                        if (!isEditing) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContentsList(
                                category: category,
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
    );
  }
}

class FolderWidget extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> topItems;
  final VoidCallback onPressed;
  final VoidCallback? onDelete;
  final bool isEditing;

  const FolderWidget({
    super.key,
    required this.category,
    required this.topItems,
    required this.onPressed,
    this.onDelete,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (int i = 0; i < topItems.length; i++) ...[
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: CachedNetworkImage(
                                      imageUrl: topItems[i]['thumbnail'],
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    topItems[i]['title'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontFamilyFallback: [],
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
                    ],
                  ),
                ),
              ),
              if (isEditing)
                Positioned(
                  top: -22,
                  left: -20,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      IconPaths.getIcon('folder_delete'),
                      width: 25,
                      height: 25,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteModal(
                          category: category,
                          onDelete:
                              onDelete ?? () => Navigator.of(context).pop(),
                        ),
                      );
                    },
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
                    fontFamilyFallback: [],
                    fontFamily: 'Four',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  "${topItems.length}",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Two',
                    fontFamilyFallback: [],
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
