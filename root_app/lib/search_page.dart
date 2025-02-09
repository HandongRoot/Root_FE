import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/icon_paths.dart';

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
      setState(() {});
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
        preferredSize: Size.fromHeight(80.h), // Responsive height
        child: Column(
          children: [
            SizedBox(height: 10.h),
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_outlined,
                    color: Color(0xFF007AFF), size: 22.sp),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: TextField(
                    controller: _controller,
                    onChanged: (text) => searchCategories(text),
                    decoration: InputDecoration(
                      hintText: '제목, 카테고리 검색..!',
                      hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 12.w),
                      border: InputBorder.none,
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Color(0xFF2E2E2E), size: 20.sp),
                              onPressed: () {
                                _controller.clear();
                                searchCategories('');
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
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
                ? Center(
                    child: Text(
                      '찾는 컨텐츠가 없어요 ㅠㅠ',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w400),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final category = searchResults[index];
                      return ExpansionTile(
                        leading: SvgPicture.asset(
                          'assets/minifolder.svg',
                          width: 35.w,
                          height: 31.h,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                          category.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Items: ${category.items.length}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                        children: category.items
                            .map((item) => ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.network(
                                          item.thumbnail,
                                          width: 58.w,
                                          height: 58.h,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              child: Image.asset(
                                                'assets/image.png',
                                                width: 58.w,
                                                height: 58.h,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                    ],
                                  ),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.url,
                                    style: TextStyle(
                                      fontSize: 15.sp,
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
