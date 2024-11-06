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
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    setState(() {
      items = data['items'];
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
            // GridView without padding
            items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0, // 4px spacing between items
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final thumbnailUrl = getThumbnailFromUrl(item['url']);
                      return ImageGridItem(imageUrl: thumbnailUrl);
                    },
                  ),
            Positioned(
              right: 10, // 스크롤바의 가로 위치
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
            // 날짜 표시 블록
            if (_showDate)
              Positioned(
                right: 40, // 스크롤바의 오른쪽에 위치하도록 조정
                top: _scrollBarPosition + 12, // 스크롤바 위치보다 5px 아래로 설정
                child: Container(
                  width: 122, // 지정된 너비
                  height: 37, // 지정된 높이
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100), // 둥근 모서리
                  ),
                  child: Text(
                    _currentDate, // 날짜 형식 맞춤
                    style: const TextStyle(
                      color: Color(0xFF2960C6), // Main 색상
                      fontFamily: 'Pretendard', // 폰트 패밀리
                      fontSize: 13, // 폰트 크기
                      fontStyle: FontStyle.normal, // 폰트 스타일
                      fontWeight: FontWeight.w500, // 폰트 굵기
                      height: 1.69231, // line-height 비율 (22px / 13px)
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    textAlign: TextAlign.center, // 텍스트 정렬
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
