import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:root_app/modals/delete_modal.dart';
import 'components/main_appbar.dart';
import 'modals/add_modal.dart';
import 'contentslist.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:root_app/utils/thumbnail_converter.dart';

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
    final data = await json.decode(response);

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
              padding: const EdgeInsets.symmetric(vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 20.0,
              ),
              itemCount: categorizedItems.length + 1,
              itemBuilder: (context, index) {
                if (index == categorizedItems.length) {
                  return GestureDetector(
                    onTap: _showAddCategoryModal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/addfolder.svg',
                          width: 162,
                        ),
                      ],
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
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20), // Matches grid padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for folder and contents
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Folder image
                SvgPicture.asset(
                  'assets/folder.svg',
                  width: 159,
                ),
                // Delete icon when editing
                if (isEditing)
                  Positioned(
                    top: -17,
                    left: -20,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteModal(
                            category: category,
                            onDelete:
                                onDelete ?? () => Navigator.of(context).pop(),
                          ),
                        );
                      },
                      //delete icon
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          IconPaths.getIcon('folder_delete'),
                        ),
                      ),
                    ),
                  ),
                // Contents inside the folder
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 29), // Space at the top
                      for (int i = 0; i < topItems.length; i++) ...[
                        Container(
                          width: 133,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: topItems[i]['thumbnail'],
                                  width: 37,
                                  height: 37,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  topItems[i]['title'],
                                  style: const TextStyle(
                                    color: Color(0xFF0A0505),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (i != topItems.length - 1)
                          const SizedBox(height: 6), // Space between items
                      ],
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Space between folder and text
            // Category Title
            Text(
              category,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Content Count
            Text(
              "${topItems.length}",
              style: const TextStyle(
                color: Color.fromRGBO(200, 200, 200, 1.0),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
