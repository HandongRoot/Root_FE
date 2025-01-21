import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Category> searchResults = [];
  TextEditingController _controller = TextEditingController();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadMockData();
    _controller.addListener(() {
      setState(() {}); // x rebuild 하는거다
    });
  }

  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    Map<String, List<Item>> categoryItems = {};
    for (var item in data['items']) {
      String category = item['category'];
      if (!categoryItems.containsKey(category)) {
        categoryItems[category] = [];
      }
      categoryItems[category]!.add(Item.fromJson(item));
    }

    setState(() {
      categories = categoryItems.entries
          .map((entry) => Category(title: entry.key, items: entry.value))
          .toList();
    });
  }

  void searchCategories(String keyword) {
    setState(() {
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AppBar(
              backgroundColor: Colors.white,
              // 내릴때 색 변하는거 방지
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined,
                    color: Color(0xFF007AFF)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) {
                      searchCategories(text);
                    },
                    decoration: InputDecoration(
                      hintText: '제목, 카테고리 검색..!',
                      hintStyle:
                          const TextStyle(fontSize: 16, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      border: InputBorder.none,
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color.fromARGB(255, 46, 46, 46)),
                              onPressed: () {
                                _controller.clear();
                                searchCategories('');
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: searchResults.isEmpty
                ? const Center(child: Text('찾는 컨텐츠가 없어요 ㅠㅠ'))
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final category = searchResults[index];
                      return ExpansionTile(
                        leading: SvgPicture.asset(
                          'assets/minifolder.svg',
                          width: 35,
                          height: 31,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          category.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text('Items: ${category.items.length}'),
                        children: category.items
                            .map((item) => ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.thumbnail, // Use thumbnail instead of image
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.asset(
                                                'assets/image.png', // Fallback image
                                                width: 58,
                                                height: 58,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.url,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
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

class Category {
  final String title;
  final List<Item> items;

  Category({
    required this.title,
    required this.items,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? 'Untitled',
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }
}

class Item {
  final String title;
  final String url;
  final String thumbnail;

  Item({
    required this.title,
    required this.url,
    required this.thumbnail,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'] ?? 'Untitled',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
