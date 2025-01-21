import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'components/main_appbar.dart';
import 'modals/delete_category_modal.dart';
import 'modals/add_modal.dart';
import 'contentslist_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:root_app/utils/thumbnail_converter.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;

  const HomePage({super.key, required this.onScrollDirectionChange});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      if (groupedByCategory[category] == null) {
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
      builder: (context) => DeleteCategoryModal(
        // Use DeleteCategoryModal here
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: categorizedItems.isEmpty
            ? const Center(child: LinearProgressIndicator())
            : GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
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
                            height: 169,
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
                            builder: (context) => ContentsListPage(
                              category: category,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
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
      child: SizedBox(
        height: 203, // colum / category title / total content num 존채 height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Folder Image with items
            Stack(
              children: [
                SvgPicture.asset(
                  'assets/folder.svg',
                  height: 144,
                  width: 159,
                ),
                if (isEditing)
                  Positioned(
                    top: -2,
                    left: -2,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 25,
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 29), // Spacer at the top

                      // Iterate over topItems with a SizedBox in between rows
                      for (int i = 0; i < topItems.length; i++) ...[
                        Container(
                          height: 49,
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
                                  placeholder: (context, thumbnail) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, thumbnail, error) =>
                                      Image.asset(
                                    'assets/image.png',
                                    width: 37,
                                    height: 37,
                                    fit: BoxFit.cover,
                                  ),
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
                        // Sizrebox inbetween rows inside stack
                        if (i != topItems.length - 1) const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15), // Spacing between rows

            // Second Row: Category name
            SizedBox(
              height: 20,
              width: 159, // Match folder width
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Third Row: 숫자
            SizedBox(
              height: 23,
              child: Text(
                "5",
                style: const TextStyle(
                  color: Color.fromRGBO(200, 200, 200, 1.0),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
