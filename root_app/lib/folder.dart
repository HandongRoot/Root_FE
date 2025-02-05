import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:root_app/modals/delete_modal.dart';
import 'components/main_appbar.dart';
import 'modals/add_modal.dart';
import 'contentslist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'utils/icon_paths.dart';

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
    loadMockData();
  }

  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = json.decode(response);

    Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    for (var item in data['items']) {
      String category = item['category'];
      if (!groupedByCategory.containsKey(category)) {
        groupedByCategory[category] = [];
      }
      groupedByCategory[category]!.add(item);
    }

    setState(() {
      categorizedItems = groupedByCategory;
    });
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
      builder: (context) => AddModal(
        controller: _newCategoryController,
        onSave: () {
          if (_newCategoryController.text.isNotEmpty) {
            setState(() {
              categorizedItems[_newCategoryController.text] = [];
            });
            _newCategoryController.clear();
            Navigator.of(context).pop();
          }
        },
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
        appBar: MainAppBar(
          isEditing: isEditing,
          onToggleEditing: _toggleEditMode,
        ),
        body: categorizedItems.isEmpty
            ? const Center(child: LinearProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 108),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0.0,
                  childAspectRatio: 0.85,
                ),
                itemCount: categorizedItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == categorizedItems.length) {
                    final double screenWidth =
                        MediaQuery.of(context).size.width;
                    final double itemWidth = screenWidth * 0.4;
                    final double folderImageHeight = itemWidth * 0.95;

                    return GestureDetector(
                      onTap: _showAddCategoryModal,
                      child: Container(
                        width: itemWidth,
                        height: folderImageHeight,
                        alignment: Alignment.topCenter,
                        child: SvgPicture.asset(
                          'assets/addfolder.svg',
                          width: itemWidth,
                          height: folderImageHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }

                  final category = categorizedItems.keys.elementAt(index);
                  final topItems = categorizedItems[category]!.take(2).toList();

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
              ));
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = screenWidth * 0.4;
    final double folderImageHeight = itemWidth * 0.95;

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/folder.svg',
                width: itemWidth,
                height: folderImageHeight,
                fit: BoxFit.contain,
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      for (int i = 0; i < topItems.length; i++) ...[
                        Container(
                          width: itemWidth * 0.9,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: topItems[i]['thumbnail'],
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  topItems[i]['title'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              // Delete icon
              if (isEditing)
                Positioned(
                  top: -20,
                  left: -20,
                  child: IconButton(
                    icon: SvgPicture.asset(
                      IconPaths.getIcon('folder_delete'),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              Text(
                category,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${topItems.length}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
