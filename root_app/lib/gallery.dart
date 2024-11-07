import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/components/sub_appbar.dart';
import 'package:root_app/utils/url_converter.dart';
import 'package:root_app/components/delete_modal.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 추가

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
  int? longPressedIndex;
  final ScrollController _scrollController = ScrollController();
  String _currentDate = "2024년 9월 1일";
  bool _showDate = false;
  double _scrollBarPosition = 0.0;
  double _previousOffset = 0.0;
  double itemSize = 128.0;

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
        return dateB.compareTo(dateA);
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

  void _showDeleteModal(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteModal(
          category: category,
          onDelete: () {
            setState(() {
              items.removeWhere((item) => item['title'] == category);
              longPressedIndex = null;
            });
          },
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Offset _calculateItemPosition(int index) {
    const int crossAxisCount = 3;
    final double x = (index % crossAxisCount) * (itemSize + 4.0);
    final double y = (index ~/ crossAxisCount) * (itemSize + 4.0);
    return Offset(x, y - _scrollController.offset);
  }

  @override
  Widget build(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    final maxScrollBarHeight = sizeY * 0.8;

    return Scaffold(
      appBar: SubAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: GestureDetector(
                onTap: () {
                  if (longPressedIndex != null) {
                    setState(() {
                      longPressedIndex = null;
                      selectedIndex = null;
                    });
                  }
                },
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
                              final itemUrl = item['url'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = selectedIndex == index ? null : index;
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    selectedIndex = null;
                                    longPressedIndex = index;
                                  });
                                },
                                child: Stack(
                                  children: [
                                    BackdropFilter(
                                      filter: longPressedIndex != null && longPressedIndex != index
                                          ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
                                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                      child: IgnorePointer(
                                        ignoring: longPressedIndex != null && longPressedIndex != index,
                                        child: ImageGridItem(
                                          imageUrl: thumbnailUrl,
                                          title: title,
                                          itemUrl: itemUrl,
                                          isSelected: selectedIndex == index,
                                          isLongPressed: longPressedIndex == index,
                                          onLinkTap: () => _launchURL(itemUrl), // Link action added here
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    if (longPressedIndex != null)
                      Positioned(
                        left: _calculateItemPosition(longPressedIndex!).dx,
                        top: _calculateItemPosition(longPressedIndex!).dy,
                        child: IgnorePointer(
                          ignoring: false,
                          child: Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Stack(
                              children: [
                                ImageGridItem(
                                  imageUrl: getThumbnailFromUrl(items[longPressedIndex!]['url']),
                                  title: items[longPressedIndex!]['title'] ?? 'No Title',
                                  itemUrl: items[longPressedIndex!]['url'],
                                  isSelected: false,
                                  isLongPressed: true,
                                  onLinkTap: () => _launchURL(items[longPressedIndex!]['url']), // Link action
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Modify action
                                    },
                                    child: SvgPicture.asset(
                                      'assets/modify.svg',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      _showDeleteModal(items[longPressedIndex!]['title'] ?? 'Unknown');
                                    },
                                    child: SvgPicture.asset(
                                      'assets/trash.svg',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGridItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String itemUrl;
  final bool isSelected;
  final bool isLongPressed;
  final VoidCallback onLinkTap; // 추가된 onLinkTap callback

  const ImageGridItem({
    required this.imageUrl,
    required this.title,
    required this.itemUrl,
    this.isSelected = false,
    this.isLongPressed = false,
    required this.onLinkTap,
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
        if (isSelected && !isLongPressed)
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 9,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  top: 76,
                  left: 48,
                  child: GestureDetector(
                    onTap: onLinkTap, // Link action added
                    child: SvgPicture.asset(
                      'assets/Link.svg',
                      width: 33,
                      height: 33,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (isLongPressed)
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.topCenter,
            child: Positioned(
              top: 9,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
