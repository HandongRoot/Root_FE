import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Category> searchResults = [];
  TextEditingController _controller = TextEditingController();

  // Example userId (this can be dynamic based on the logged-in user)
  final String userId = "1dd1b11d-01c8-4434-8362-e72ae2c0b963";

  // Function to fetch categories from backend based on keyword search
  Future<void> searchCategories(String keyword, String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://172.18.149.24:8080/api/category/$userId/search?keyword=$keyword'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          searchResults = (json.decode(response.body) as List)
              .map((categoryJson) => Category.fromJson(categoryJson))
              .toList();
        });
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search by Title',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      searchCategories(_controller.text, userId);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? Center(child: Text('No results found'))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final category = searchResults[index];
                      return ListTile(
                        title: Text(
                          category.title,
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                          maxLines: 1,
                        ),
                        subtitle:
                            Text('Contents count: ${category.countContents}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Model class for Category
class Category {
  final String title;
  final int countContents;

  Category({
    required this.title,
    required this.countContents,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? 'Untitled', // Handle null values
      countContents: json['countContents'] ?? 0, // Handle null values
    );
  }
}
