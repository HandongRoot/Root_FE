import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/components/sub_appbar.dart';

class Gallery extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;
  final Function(bool) onSelectionModeChanged;
  final Function(Set<int>) onItemSelected;

  const Gallery({
    Key? key,
    required this.onScrollDirectionChange,
    required this.onSelectionModeChanged,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<dynamic> items = [];
  final ScrollController _scrollController = ScrollController();
  double _scrollBarPosition = 0.0;
  double _previousScrollOffset = 0.0;
  bool _showDate = false;
  String _currentDate = "2024년 9월 1일";

  bool isSelecting = false;
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    loadMockData();
  }

  Future<void> loadMockData() async {
    final String response = await rootBundle.loadString('assets/mock_data.json');
    final data = json.decode(response);

    setState(() {
      items = data['items'];
      items.sort((a, b) {
        DateTime dateA = DateTime.parse(a['dateAdded']);
        DateTime dateB = DateTime.parse(b['dateAdded']);
        return dateB.compareTo(dateA);
      });
    });
  }

  void _onScroll() {
    if (items.isNotEmpty) {
      double scrollOffset = _scrollController.offset;
      double itemHeight = 131.0;
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

      bool isScrollingUp = _scrollController.offset < _previousScrollOffset;
      widget.onScrollDirectionChange(isScrollingUp);
      _previousScrollOffset = _scrollController.offset;
    }
  }

  /// 선택 모드 변경
  void toggleSelectionMode(bool selecting) {
    setState(() {
      isSelecting = selecting;
      if (!selecting) {
        selectedItems.clear();
        widget.onItemSelected(selectedItems);
      }
    });
    widget.onSelectionModeChanged(selecting);
  }

  /// 아이템 선택/해제
  void toggleItemSelection(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
      widget.onItemSelected(selectedItems);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxScrollBarHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      appBar: SubAppBar(
        onSelectionModeChanged: toggleSelectionMode,
      ),
      body: Stack(
        children: [
          items.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(3),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final thumbnailUrl = item['thumbnail'];
                    return GestureDetector(
                      onTap: () {
                        if (isSelecting) {
                          toggleItemSelection(index);
                        }
                      },
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/image.png',
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isSelecting)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: GestureDetector(
                                onTap: () => toggleItemSelection(index),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    color: selectedItems.contains(index)
                                        ? Color(0xFF2960C6)
                                        : Colors.transparent,
                                  ),
                                  child: selectedItems.contains(index)
                                      ? Icon(Icons.check, color: Colors.white, size: 14)
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
          if (!isSelecting)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: [0.6285, 1.0],
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
                  _scrollBarPosition =
                      _scrollBarPosition.clamp(0, maxScrollBarHeight);

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
                  style: TextStyle(
                    color: Color(0xFF2960C6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
