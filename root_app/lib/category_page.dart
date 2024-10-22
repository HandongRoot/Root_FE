import 'dart:convert'; // For handling JSON data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:root_app/components/main_appbar.dart'; // For custom AppBar
import 'package:cached_network_image/cached_network_image.dart'; // For image caching
import 'package:root_app/utils/url_converter.dart'; // Import the URL utility for thumbnail

class CategoryPage extends StatefulWidget {
  final String category;

  // Constructor requiring the category to be displayed
  const CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> items = []; // List of items in the category

  @override
  void initState() {
    super.initState();
    loadItemsByCategory(); // Load items for the selected category on initialization
  }

  // Asynchronously loads items from the selected category by reading from mock_data.json
  Future<void> loadItemsByCategory() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response); // Decode the JSON file into a Map

    // Filter the items to only include those from the selected category
    setState(() {
      items = data['items']
          .where((item) =>
              item['category'] == widget.category) // Filter by category
          .toList(); // Convert filtered items to a List
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: items.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator(), // Show a loading spinner while items are being loaded
            )
          : ListView.builder(
              itemCount: items.length, // Number of items in the list
              itemBuilder: (context, index) {
                final item = items[index]; // Get each item
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: getThumbnailFromUrl(
                        item['url']), // Use the utility to get thumbnail URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
// ! url issue errorWidget image 으로 변경
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/image.png',
                      width: 37,
                      height: 37,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item['title']), // Display the item's title
                  subtitle: Text(item['url']), // Display the item's URL
                );
              },
            ),
    );
  }
}
