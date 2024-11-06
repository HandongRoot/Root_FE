import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/components/main_appbar.dart';
import 'package:root_app/utils/url_converter.dart';

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class Gallery extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;

  Gallery({required this.onScrollDirectionChange});

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  Map<String, List<dynamic>> groupedItems = {};
  final ScrollController _scrollController = ScrollController();
  String _currentDate = "2024년 9월 1일";
  bool _showDate = false;
  double _scrollBarPosition = 0.0;
  double _previousOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadMockData();
  }

  Future<void> loadMockData() async {
    final String response = await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);
    final items = data['items'];

    // 최신 날짜 순으로 정렬 및 날짜별로 그룹화
    items.sort((a, b) {
      DateTime dateA = DateTime.parse(a['dateAdded']);
      DateTime dateB = DateTime.parse(b['dateAdded']);
      return dateB.compareTo(dateA);
    });

    Map<String, List<dynamic>> groupedData = {};
    for (var item in items) {
      String date = item['dateAdded'];
      if (groupedData[date] == null) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(item);
    }

    setState(() {
      groupedItems = groupedData;
    });
  }

  void _scrollListener() {
    if (groupedItems.isNotEmpty) {
      double scrollOffset = _scrollController.offset;
      double itemHeight = 200.0;
      int firstVisibleIndex = (scrollOffset / itemHeight).floor();
      List<String> dates = groupedItems.keys.toList();

      if (firstVisibleIndex >= 0 && firstVisibleIndex < dates.length) {
        setState(() {
          _currentDate = dates[firstVisibleIndex] ?? _currentDate;
        });
      }

      double scrollFraction = _scrollController.position.pixels /
          _scrollController.position.maxScrollExtent;
      _scrollBarPosition =
          scrollFraction * (MediaQuery.of(context).size.height * 0.8);

      if (_scrollController.offset > _previousOffset) {
        widget.onScrollDirectionChange(false);
      } else {
        widget.onScrollDirectionChange(true);
      }
      _previousOffset = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    final maxScrollBarHeight = sizeY * 0.8;

    return Scaffold(
      appBar: MainAppBar(),
      body: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: Stack(
          children: [
            groupedItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: groupedItems.keys.length,
                    itemBuilder: (context, index) {
                      String date = groupedItems.keys.elementAt(index);
                      List<dynamic> items = groupedItems[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, gridIndex) {
                              final item = items[gridIndex];
                              final thumbnailUrl = getThumbnailFromUrl(item['url']);
                              return ImageGridItem(imageUrl: thumbnailUrl);
                            },
                          ),
                        ],
                      );
                    },
                  ),
            Positioned(
              right: 10,
              top: 10,
              bottom: 10,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _scrollBarPosition += details.delta.dy;
                    _scrollBarPosition = _scrollBarPosition.clamp(0, maxScrollBarHeight);

                    double scrollFraction = _scrollBarPosition / maxScrollBarHeight;
                    _scrollController.jumpTo(
                      scrollFraction * _scrollController.position.maxScrollExtent,
                    );

                    _showDate = true;
                  });
                },
                onVerticalDragEnd: (details) {
                  setState(() {
                    _showDate = false;
                  });
                },
                child: Container(
                  width: 20,
                  height: maxScrollBarHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: _scrollBarPosition,
                        child: SvgPicture.asset(
                          'assets/scroll.svg',
                          width: 20,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showDate)
              Positioned(
                right: 40,
                top: _scrollBarPosition + 5,
                child: Container(
                  width: 122,
                  height: 37,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _currentDate,
                    style: const TextStyle(
                      color: Color(0xFF2960C6),
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w500,
                      height: 1.69231,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ImageGridItem extends StatelessWidget {
  final String imageUrl;

  const ImageGridItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Image.asset(
          'assets/image.png',
          width: 37,
          height: 37,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
