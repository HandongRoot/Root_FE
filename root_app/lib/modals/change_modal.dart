import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/utils/icon_paths.dart';

class ChangeModal extends StatefulWidget {
  final Map<String, dynamic> item;

  const ChangeModal({required this.item});

  @override
  _ChangeModalState createState() => _ChangeModalState();
}

class _ChangeModalState extends State<ChangeModal> {
  Map<String, List<Map<String, dynamic>>> categorizedItems = {};

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double modalHeight = screenHeight * 0.7;
    if (modalHeight > 606) {
      modalHeight = 606;
    }

    return Container(
      height: modalHeight,
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("취소",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              const Text(
                "이동할 폴 더 선택",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400),
              ),
              IconButton(
                onPressed: () {
                  // Handle Add icon button action
                  print("Add Icon Pressed");
                },
                icon: SvgPicture.asset(
                  IconPaths.getIcon('add_folder'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: categorizedItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.05,
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: categorizedItems.length,
                    itemBuilder: (context, index) {
                      final category = categorizedItems.keys.elementAt(index);
                      final topItems =
                          categorizedItems[category]!.take(2).toList();
                      return _buildGridItem(category, topItems, screenWidth);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String category, List<Map<String, dynamic>> topItems,
      double screenWidth) {
    double itemWidth = screenWidth * 0.4;
    double itemHeight = itemWidth * 1.28;

    // Responsive font sizes based on screen width
    double categoryFontSize = screenWidth * 0.045; // About 4.5% of screen width
    double itemCountFontSize =
        screenWidth * 0.035; // About 3.5% of screen width

    return Container(
      width: itemWidth,
      height: itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SvgPicture.asset(
                'assets/modal_folder.svg',
                width: itemWidth,
                height: itemHeight * 0.6,
                fit: BoxFit.contain,
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    for (int i = 0; i < topItems.length; i++) ...[
                      Container(
                        width: itemWidth * 0.9,
                        padding: const EdgeInsets.all(6.0),
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                topItems[i]['title'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: categoryFontSize * 0.75,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
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
          // Responsive category name font size
          Text(
            category,
            style: TextStyle(
              fontSize: categoryFontSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
          Text(
            "${topItems.length} items",
            style: TextStyle(
              color: Colors.grey,
              fontSize: itemCountFontSize,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
