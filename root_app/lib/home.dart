import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'components/main_appbar.dart';
import 'category_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For efficient image caching
import 'package:root_app/utils/url_converter.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onScrollDirectionChange; // 스크롤 방향 변화 콜백 추가

  const HomePage({super.key, required this.onScrollDirectionChange});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Store items by category
  Map<String, List<Map<String, dynamic>>> categorizedItems = {};
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러
  double _previousOffset = 0.0; // 이전 스크롤 위치 저장

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener); // 스크롤 리스너 추가
    loadMockData(); // Load mock data
  }

  /*
   * Loads mock data from the JSON file in the assets folder.
   */
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    // Group items by category into a Map
    Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    for (var item in data['items']) {
      String category = item['category'];
      if (groupedByCategory[category] == null) {
        groupedByCategory[category] = [];
      }
      groupedByCategory[category]!.add(item);
    }

    // Rebuild the UI with updated data
    setState(() {
      categorizedItems = groupedByCategory;
    });
  }

  /*
   * Scroll listener function to detect scroll direction.
   */
  void _scrollListener() {
    if (_scrollController.offset > _previousOffset) {
      widget.onScrollDirectionChange(false); // 아래로 스크롤 시 네비게이션 바 숨김
    } else {
      widget.onScrollDirectionChange(true); // 위로 스크롤 시 네비게이션 바 표시
    }
    _previousOffset = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 스크롤 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: categorizedItems.isEmpty
            ? const Center(child: LinearProgressIndicator())
            : GridView.builder(
                controller: _scrollController, // 스크롤 컨트롤러 추가
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Grid items per row
                  childAspectRatio: 0.8, // Adjust this to fit content better
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/folder.svg',
                  height: 169,
                  width: 162,
                  fit: BoxFit.cover,
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32), // 안에 item 두개 위에 공간
                        ...topItems.map((item) => Container(
                              // 안에 흰색 item 크기
                              height: 49,
                              width: 132,
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(13),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          getThumbnailFromUrl(item['url']),
                                      width: 37,
                                      height: 37,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/image.png',
                                        width: 37,
                                        height: 37,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      item['title'],
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
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
