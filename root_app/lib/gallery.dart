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
  List<dynamic> items = [];
  int? selectedIndex;
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

    setState(() {
      items = data['items'];
      items.sort((a, b) {
        DateTime dateA = DateTime.parse(a['dateAdded']);
        DateTime dateB = DateTime.parse(b['dateAdded']);
        return dateB.compareTo(dateA); // 최신 날짜가 먼저 오도록 내림차순 정렬
      });
    });
  }

  void _scrollListener() {
    if (items.isNotEmpty) {
      double scrollOffset = _scrollController.offset;
      double itemHeight = 200.0;
      int firstVisibleIndex = (scrollOffset / itemHeight).floor();

      if (firstVisibleIndex >= 0 && firstVisibleIndex < items.length) {
        setState(() {
          _currentDate = items[firstVisibleIndex]['dateAdded'] ?? _currentDate;
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
            items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final thumbnailUrl = getThumbnailFromUrl(item['url']);
                      final title = item['title'] ?? 'No Title';
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: ImageGridItem(
                          imageUrl: thumbnailUrl,
                          title: title,
                          isSelected: selectedIndex == index,
                        ),
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
                top: _scrollBarPosition + 12,
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
  final String title;
  final bool isSelected;

  const ImageGridItem({
    required this.imageUrl,
    required this.title,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset(
              'assets/image.png',
              width: 128,
              height: 128,
              fit: BoxFit.cover,
            ),
            width: 128,
            height: 128,
            fit: BoxFit.cover,
          ),
        ),
        // 전체 오버레이 추가
        if (isSelected)
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
