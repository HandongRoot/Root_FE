import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'components/main_appbar.dart';
import 'category_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For efficient image caching
import 'package:root_app/utils/url_utils.dart'; // Import the utility

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Store items by category
  Map<String, List<Map<String, dynamic>>> categorizedItems = {};

  @override
  void initState() {
    super.initState();
    loadMockData(); // Load mock data
  }

  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    // Group items by category into a Map
    Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    for (var item in data['items']) {
      String category = item['category']; // Get category name
      if (groupedByCategory[category] == null) {
        groupedByCategory[category] = [];
      }
      groupedByCategory[category]!.add(item); // Add item to its category
    }

    // Rebuild the UI with updated data
    setState(() {
      categorizedItems = groupedByCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: categorizedItems.isEmpty
            ? const Center(child: LinearProgressIndicator())
            //TODO: grid view layout 수정해야함 !!! bottom overflow
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Grid items per row
                  childAspectRatio: 1, // Ensure square grid cells
                ),
                itemCount: categorizedItems.length,
                itemBuilder: (context, index) {
                  final category = categorizedItems.keys.elementAt(index);
                  final topItems = categorizedItems[category]!.take(2).toList();

                  return FolderWidget(
                    category: category,
                    topItems: topItems,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryPage(
                            category: category,
                          ),
                        ),
                      );
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

  const FolderWidget({
    super.key,
    required this.category,
    required this.topItems,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder background and top items overlay
          Stack(
            children: [
              SvgPicture.asset(
                'assets/folder.svg',
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topItems
                        .map((item) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  // Item image using the URL utility
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: getThumbnailFromUrl(item[
                                          'url']), // Use the utility function to get thumbnail URL
                                      width: 37,
                                      height: 37,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Item title
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: const TextStyle(
                                        color: Color(0xFF0A0505),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Category name text
          Text(
            category,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
