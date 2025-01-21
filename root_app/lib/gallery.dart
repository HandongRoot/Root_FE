import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/components/sub_appbar.dart';
import 'package:root_app/modals/delete_item_modal.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

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
  Set<int> activeItems = {};

  bool _showScrollBar = true;
  Timer? _scrollBarTimer;

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

      _resetScrollBarVisibility();
    }
  }

  void _resetScrollBarVisibility() {
    setState(() {
      _showScrollBar = true;
    });

    _scrollBarTimer?.cancel();
    _scrollBarTimer = Timer(Duration(seconds: 2), () {
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          _showScrollBar = false;
        });
      });
    });
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

  // 선택된 아이템 삭제 모달 띄우기
  void _showDeleteModal(BuildContext context) {
    if (selectedItems.isEmpty) return; //선택 항목이 없으면 return

    final List<Map<String, dynamic>> selectedItemsList = 
      selectedItems.map((index) => items[index] as Map<String, dynamic>).toList();

    showDialog(
      context: context,
      builder: (context) => DeleteItemModal(
        item: selectedItemsList.first,
        onDelete: () => _deleteSelectedItems(),
      ),
    );
  }

  // 선택된 아이템 삭제
  void _deleteSelectedItems() {
    setState(() {
      items.removeWhere((item) => selectedItems.contains(items.indexOf(item)));
      selectedItems.clear();
      isSelecting = false;
    });
    widget.onSelectionModeChanged(false);
  }

  void toggleItemView(int index) {
    setState(() {
      if (activeItems.contains(index)) {
        activeItems.remove(index);
      } else {
        activeItems.add(index);
      }
    });
  }

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollBarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxScrollBarHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      appBar: SubAppBar(
        onSelectionModeChanged: toggleSelectionMode,
        onDeletePressed: () => _showDeleteModal(context),  // 삭제 버튼 이벤트
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
                    final title = item['title'];
                    final contentUrl = item['url'];
                    bool isActive = activeItems.contains(index);

                    return GestureDetector(
                      onTap: () {
                        if (isSelecting) {
                          toggleItemSelection(index);
                        } else {
                          toggleItemView(index);
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

                          if (isActive) ... [
                            Container(
                              width: 128,
                              height: 128,
                              color: Colors.black.withOpacity(0.6),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 제목 표시
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                      fontFamily: 'Pretendard',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Spacer(),
                                  // 링크 버튼
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => _openUrl(contentUrl),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Color(0xFFFCFCFC), width: 1.5),
                                        ),
                                        child: Icon(Icons.link, color: Colors.white, size: 20),
                                      ),
                                    ),
                                    ),
                                ],
                                ),
                                ),
                          ],

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
            if (_showScrollBar)
          Positioned(
            right: 10,
            top: 10,
            bottom: 10,
            child: AnimatedOpacity(
              opacity: _showScrollBar ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
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
