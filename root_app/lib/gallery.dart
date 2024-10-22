import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart'; // image caching 할때 쓰는거래
import 'package:root_app/components/main_appbar.dart';
import 'package:root_app/utils/url_converter.dart'; // Import the utility

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

//TODO: 아이콘 눌렀을때 그 줌 되는거 예..
//TODO: 사실 이거 ㅋㅋㅋㅋ 임성빈이 구현한 scroll chatGPT 한테 함성해달라해서 해준건데 일단 스크롤 height 이랑 뭐
// 이것저것 수정이 부족한 것 같아서 그거 수정해야함. 그래서 ㅋㅋ 임성빈이 만든거 chapGPT가 친절하세 주석 달아줌 ㅋㅋㅋ
class _GalleryState extends State<Gallery> {
  List<dynamic> items = []; // List to store gallery items from mock data
  final ScrollController _scrollController = ScrollController();
  String _currentDate =
      "2024년 9월 1일"; // Display the date based on scroll position
  bool _showDate = false; // Control visibility of the date display
  double _scrollBarPosition = 0.0; // Keep track of scrollbar position

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener); // Attach scroll listener
    loadMockData(); // Load mock data when the page initializes
  }

  /*
   * Loads mock data from the JSON file in the assets folder.
   */
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    // mock data 에 있응 items  으로  list update 해줌
    setState(() {
      items = data['items'];
    });
  }

  /*
   * Scroll listener function to track the scroll position and adjust date and scrollbar position.
   */
  void _scrollListener() {
    if (items.isNotEmpty) {
      double scrollOffset = _scrollController.offset; // Get scroll offset
      double itemHeight = 200.0; // Approximate height of each grid item
      int firstVisibleIndex = (scrollOffset / itemHeight)
          .floor(); // Find the first visible item index

      if (firstVisibleIndex >= 0 && firstVisibleIndex < items.length) {
        // Update the displayed date with the date of the first visible item
        setState(() {
          _currentDate = items[firstVisibleIndex]['dateAdded'] ?? _currentDate;
        });
      }

      // Update scrollbar position based on scroll percentage
      double scrollFraction = _scrollController.position.pixels /
          _scrollController.position.maxScrollExtent;
      _scrollBarPosition =
          scrollFraction * (MediaQuery.of(context).size.height * 0.8);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height; // Screen height
    final maxScrollBarHeight =
        sizeY * 0.8; // Maximum height for custom scrollbar

    return Scaffold(
      appBar: MainAppBar(),
      body: Stack(
        children: [
          // Main content - Grid view of thumbnails
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: items.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator()) // 이거 그냥 추가해봤어 히히힣ㅎ 로딩할때 그 동그란거 나오는거야
                : GridView.builder(
                    controller: _scrollController, // Attach scroll controller
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Two images per row
                    ),
                    itemCount: items.length, // Total number of items
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final thumbnailUrl = getThumbnailFromUrl(item[
                          'url']); // /utility/ url_converter.dart 에서 url 주고 바꾸는거임~
                      return ImageGridItem(
                          imageUrl: thumbnailUrl); // Render grid item
                    },
                  ),
          ),
          // Custom scrollbar to allow dragging
          Positioned(
            right: 10,
            top: 10,
            bottom: 10,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _scrollBarPosition +=
                      details.delta.dy; // Update scrollbar position
                  _scrollBarPosition = _scrollBarPosition.clamp(
                      0, maxScrollBarHeight); // Clamp scrollbar position

                  // Scroll the content based on scrollbar position
                  double scrollFraction =
                      _scrollBarPosition / maxScrollBarHeight;
                  _scrollController.jumpTo(
                    scrollFraction * _scrollController.position.maxScrollExtent,
                  );

                  _showDate = true; // Show date while scrolling
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  _showDate = false; // Hide date after scrolling ends
                });
              },
              child: Container(
                width: 20,
                height: maxScrollBarHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: _scrollBarPosition,
                      child: Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Date display when scrolling
          if (_showDate)
            Positioned(
              right: 40,
              top: _scrollBarPosition,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentDate, // Display the current date
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/*
 * ImageGridItem - 그리드 한 칸에 들어가는거
 */
class ImageGridItem extends StatelessWidget {
  final String imageUrl; // The image URL  ( 변한된 url)

  const ImageGridItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl, // Fetch image from the URL
        placeholder: (context, url) =>
            CircularProgressIndicator(), // Show loading spinner
        errorWidget: (context, url, error) =>
            Icon(Icons.error), // Show error icon on failure
        fit: BoxFit.cover, // Ensure the image fits within the container
      ),
    );
  }
}
