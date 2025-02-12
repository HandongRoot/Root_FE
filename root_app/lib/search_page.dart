import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/icon_paths.dart';

/// 콘텐츠츠
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

/// 카테고리
class Category {
  final String title;
  Category({
    required this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? 'Untitled',
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Item> contentResults = [];
  List<Category> categoryResults = [];
  bool isLoading = false;

  final String userId = 'ba44983b-a95b-4355-83d7-e4b23df91561';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final query = _controller.text.trim();
      if (query.isNotEmpty) {
        searchAll(query);
      } else {
        setState(() {
          contentResults.clear();
          categoryResults.clear();
        });
      }
    });
  }

  Future<void> searchAll(String query) async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      searchContents(query),
      searchCategories(query),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> searchContents(String query) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    final String endpoint =
        "/api/v1/content/search/$userId?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";
    try {
      final response =
          await http.get(Uri.parse(requestUrl), headers: {"Accept": "*/*"});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          contentResults = data.map((json) => Item.fromJson(json)).toList();
        });
      } else {
        throw Exception("Failed to load content search data");
      }
    } catch (e) {
      print("Error searching contents: $e");
    }
  }

  Future<void> searchCategories(String query) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    final String endpoint =
        "/api/v1/category/search/$userId?title=${Uri.encodeComponent(query)}";
    final String requestUrl = "$baseUrl$endpoint";
    try {
      final response =
          await http.get(Uri.parse(requestUrl), headers: {"Accept": "*/*"});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          categoryResults =
              data.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        throw Exception("Failed to load category search data");
      }
    } catch (e) {
      print("Error searching categories: $e");
    }
  }

  Widget _highlightSearchText(String text, String searchText) {
    if (searchText.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 16.sp));
    }
    final lowerText = text.toLowerCase();
    final lowerSearch = searchText.toLowerCase();
    if (!lowerText.contains(lowerSearch)) {
      return Text(text, style: TextStyle(fontSize: 16.sp));
    }
    final startIndex = lowerText.indexOf(lowerSearch);
    final endIndex = startIndex + searchText.length;
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(color: Color(0xFF2960C6)),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(305.w, 45.h),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,
                color: Color(0xFF007AFF), size: 22.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
            width: 305.w,
            height: 45.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.all(11.w),
            child: Center(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '제목, 카테고리 검색..!',
                  hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  border: InputBorder.none,
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Color(0xFF2E2E2E), size: 20.sp),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              contentResults.clear();
                              categoryResults.clear();
                            });
                          },
                        )
                      : null,
                ),
                style: TextStyle(fontSize: 16.sp, color: Colors.black),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _controller.text.trim().isEmpty
              ? Center(
                  child: Text("검색어를 입력하세요.", style: TextStyle(fontSize: 18.sp)),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 결과
                      if (categoryResults.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "폴더",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: 'Six',
                                  color: Color(0xFF2960C6)),
                            ),
                            SizedBox(height: 10.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: categoryResults.length,
                              itemBuilder: (context, index) {
                                final cat = categoryResults[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Row(
                                    children: [
                                      // TODO 바꿔야함
                                      SvgPicture.asset(
                                        'assets/minifolder.svg',
                                        width: 35.w,
                                        height: 31.h,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(width: 10.w),
                                      // 파란색으로 highlight
                                      Flexible(
                                        child: _highlightSearchText(
                                          cat.title,
                                          _controller.text.trim(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 40.h),
                      // 콘텐츠 결과
                      if (contentResults.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "콘텐츠",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontFamily: 'Six',
                                  color: Color(0xFF2960C6)),
                            ),
                            SizedBox(height: 10.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: contentResults.length,
                              itemBuilder: (context, index) {
                                final item = contentResults[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Row(
                                    children: [
                                      // 썸넬
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: CachedNetworkImage(
                                          imageUrl: item.thumbnail,
                                          width: 58.w,
                                          height: 58.h,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            'assets/image.png',
                                            width: 58.w,
                                            height: 58.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      // 콘텐츠 row
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _highlightSearchText(item.title,
                                                _controller.text.trim()),
                                            SizedBox(height: 4.h),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (categoryResults.isEmpty &&
                          contentResults.isEmpty &&
                          _controller.text.trim().isNotEmpty)
                        Center(
                          child: Text(
                            '검색 결과가 없습니다.',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
