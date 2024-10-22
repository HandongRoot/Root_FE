import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:root_app/components/main_appbar.dart';

/*
 * SearchPage is a stateful widget that allows searching through categories and item titles.
 * It loads data from a mock JSON file and displays the search results in an expandable list.
 */
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Category> searchResults = []; // List of search results
  TextEditingController _controller =
      TextEditingController(); // Controller for search input
  List<Category> categories =
      []; // List of all categories loaded from the mock data

  @override
  void initState() {
    super.initState();
    loadMockData(); // Load categories and items from the mock_data.json file when the page initializes
  }

  /*
   * Loads mock data from assets/mock_data.json and extracts categories and their respective items.
   */
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json'); // Load JSON file
    final data = await json.decode(response); // Decode the JSON data

    // Group items by category
    Map<String, List<Item>> categoryItems = {};
    for (var item in data['items']) {
      String category = item['category'];
      if (!categoryItems.containsKey(category)) {
        categoryItems[category] = [];
      }
      categoryItems[category]!
          .add(Item.fromJson(item)); // Add items to their respective category
    }

    // Convert the grouped data into a list of Category objects
    setState(() {
      categories = categoryItems.entries
          .map((entry) => Category(title: entry.key, items: entry.value))
          .toList();
    });
  }

  /*
   * Function to search both categories and item titles based on the keyword entered by the user.
   * The search is case-insensitive.
   */
  void searchCategories(String keyword) {
    setState(() {
      // Filter categories that match the keyword or contain items that match the keyword
      searchResults = categories
          .where((category) =>
              category.title.toLowerCase().contains(keyword.toLowerCase()) ||
              category.items.any((item) =>
                  item.title.toLowerCase().contains(keyword.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller, // Text controller for search input
              decoration: InputDecoration(
                labelText: 'Search by Title or Category', // Search hint text
                suffixIcon: IconButton(
                  icon: Icon(Icons.search), // Search icon
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      searchCategories(_controller
                          .text); // Perform search when the icon is pressed
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Text(
                        'No results found')) // Show message if no results are found
                : ListView.builder(
                    itemCount:
                        searchResults.length, // Number of categories found
                    itemBuilder: (context, index) {
                      final category = searchResults[index];
                      return ExpansionTile(
                        title: Text(
                          category.title, // Show category title
                          overflow: TextOverflow
                              .ellipsis, // Handle long titles with ellipsis
                          maxLines: 1, // Limit to one line
                        ),
                        subtitle: Text(
                          'Items: ${category.items.length}', // Display the number of items in the category
                        ),
                        // Expandable list to show the items within the category
                        children: category.items
                            .map((item) => ListTile(
                                  title: Text(item.title), // Show item title
                                  subtitle: Text(item.url), // Show item URL
                                  leading: Image.asset(
                                    item.image, // Display the item image
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit
                                        .cover, // Ensure the image fits within the box
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/*
 * Model class representing a category.
 * A Category has a title and a list of items associated with it.
 */
class Category {
  final String title;
  final List<Item> items;

  Category({
    required this.title,
    required this.items,
  });

  /*
   * Factory method to create a Category from a JSON map.
   */
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? 'Untitled', // Handle null values for title
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item)) // Parse the list of items
          .toList(),
    );
  }
}

/*
 * Model class representing an item.
 * An Item has a title, URL, and image.
 */
class Item {
  final String title;
  final String url;
  final String image;

  Item({
    required this.title,
    required this.url,
    required this.image,
  });

  /*
   * Factory method to create an Item from a JSON map.
   */
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'] ?? 'Untitled', // Handle null values for title
      url: json['url'] ?? '', // Default to empty string if URL is missing
      image: json['image'] ?? '', // Default to empty string if image is missing
    );
  }
}
