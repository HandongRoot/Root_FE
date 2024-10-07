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
  final String userId = "12345";

  // Function to fetch categories from backend based on keyword search
  Future<void> searchCategories(String keyword, String userId) async {
    final response = await http.get(
      Uri.parse(
          'http://172.18.149.24:3000/api/category/$userId/search?keyword=$keyword'), // Adjust the URL to match your backend
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResults = (json.decode(response.body) as List)
            .map((categoryJson) => Category.fromJson(categoryJson))
            .toList();
      });
    } else {
      throw Exception('Failed to load categories');
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
                      // Trigger search with both keyword and userId
                      searchCategories(_controller.text, userId);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final category = searchResults[index];
                return ListTile(
                  title: Text(category.title), // Displaying the category title
                  subtitle: Text(category
                      .description), // Displaying the category description
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
  final String description;

  Category({required this.title, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'],
      description: json['description'],
    );
  }
}
