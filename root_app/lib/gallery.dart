import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/components/gallery_appbar.dart';
import 'package:root_app/modals/delete_item_modal.dart';
import 'package:root_app/modals/long_press_modal.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'utils/icon_paths.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Gallery extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;
  final Function(bool) onSelectionModeChanged;
  final Function(Set<int>) onItemSelected;
  final String userId;

  const Gallery({
    Key? key,
    required this.onScrollDirectionChange,
    required this.onSelectionModeChanged,
    required this.onItemSelected,
    required this.userId,
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
  int? activeItemIndex;

  bool _showScrollBar = true;
  Timer? _scrollBarTimer;

  Offset? modalPosition;
  String? modalImageUrl;
  String? modalTitle;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    loadMockData(widget.userId);
  }

  Future<void> loadMockData(String userId) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    final String endpoint = "/api/v1/content/findAll/$userId";
    final String requestUrl = "$baseUrl$endpoint";

    try {
      final response =
          await http.get(Uri.parse(requestUrl), headers: {"Accept": "*/*"});

      print("🔹 API Response: ${response.body}"); // 📌 API 응답 출력

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        for (var item in data) {
          print("🧐 Decoded Title: ${item['title']}"); // ✅ 제목이 정상 출력되는지 확인
        }

        setState(() {
          items = data; // 📌 여기서 변형될 가능성 있음

          // setState 후 데이터 다시 확인
          for (var item in items) {
            print("🚨 After setState linkedUrl: ${item['linkedUrl']}");
          }

          items.sort((a, b) {
            DateTime dateA = DateTime.parse(a['createdDate']);
            DateTime dateB = DateTime.parse(b['createdDate']);
            return dateB.compareTo(dateA);
          });
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
    }
  }

  void _editItemTitle(int index, String newTitle) {
    setState(() {
      items[index]['title'] = newTitle;
    });
  }

  void _deleteSelectedItem(int index) {
    setState(() {
      items.removeAt(index);
      selectedItems.remove(index);
      isSelecting = false;
    });
    widget.onSelectionModeChanged(false);
  }

  void showLongPressModal(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double modalWidth = 240;
    const double modalY = 0; // 최상단 정렬

    setState(() {
      activeItemIndex = index;
      modalPosition = Offset((screenWidth - modalWidth) / 2, modalY); // 중앙 정렬
      modalImageUrl = items[index]['thumbnail'];
      modalTitle = items[index]['title'];
    });

    debugPrint("Screen Width: $screenWidth");
    debugPrint("Modal X Position: ${screenWidth / 2}");
  }

  void hideLongPressModal() {
    setState(() {
      activeItemIndex = null;
      modalPosition = null;
      modalImageUrl = null;
      modalTitle = null;
    });
  }

  // 스크롤에 따라서 navbar 사라지도록 하는 부분.
  void _onScroll() {
    if (items.isNotEmpty) {
      double scrollOffset = _scrollController.offset;
      double itemHeight = 131.0;
      int itemsPerRow = 3;
      int firstVisibleRowIndex = (scrollOffset / itemHeight).floor();
      int firstVisibleIndex = firstVisibleRowIndex * itemsPerRow;

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
      // widget.onScrollDirectionChange(isScrollingUp);
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
      }
    });
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

    final List<Map<String, dynamic>> selectedItemsList = selectedItems
        .map((index) => items[index] as Map<String, dynamic>)
        .toList();

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
      if (activeItemIndex == index) {
        activeItemIndex = null;
      } else {
        activeItemIndex = index;
      }
    });
  }

  void clearActiveItem() {
    if (activeItemIndex != null) {
      setState(() {
        activeItemIndex = null;
      });
    }
  }

  void _openUrl(String url) async {
    print("Opending URL: $url");
    final Uri uri = Uri.tryParse(url) ?? Uri();

    if (uri.scheme.isEmpty) {
      print("x URL에 스킴이 없습니다: $url");
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("x url 실행 실패: $url");
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

    return Stack(
      children: [
        /// 🔹 길게 눌렀을 때 전체 화면 blur 처리 (GalleryAppBar, NavigationBar 포함)
        if (activeItemIndex != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: hideLongPressModal,
              child: Container(
                color: Colors.white.withOpacity(0.45),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(),
                ),
              ),
            ),
          ),

        Scaffold(
          appBar: GalleryAppBar(
            isSelecting: isSelecting,
            onSelectionModeChanged: toggleSelectionMode,
            onDeletePressed: () => _showDeleteModal(context),
            onClearActiveItem: clearActiveItem,
          ),
          body: Stack(
            children: [
              items.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                          top: 0, left: 0, right: 0, bottom: 130),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final thumbnailUrl = item['thumbnail'] ?? '';
                        final title = item['title'] ?? 'No Title';
                        final contentUrl = item['linkedUrl'] ?? '#';

                        bool isActive = activeItemIndex == index;

                        return GestureDetector(
                          onTap: () {
                            if (isSelecting) {
                              toggleItemSelection(index);
                            } else {
                              toggleItemView(index);
                            }
                          },
                          onLongPress: isSelecting
                              ? null
                              : () => showLongPressModal(index),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (isActive) ...[
                                Container(
                                  width: 128,
                                  height: 128,
                                  color: Colors.black.withOpacity(0.6),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        // 🔹 추가: overflow 방지
                                        height: 34,
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2,
                                            fontFamily: 'Pretendard',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis, // 🔹 너무 긴 경우 ... 처리
                                        ),
                                      ),
                                      SizedBox(height: 35),
                                      Flexible(
                                        child: Center(
                                            child: GestureDetector(
                                          onTap: () => _openUrl(contentUrl),
                                          child: SvgPicture.asset(
                                            IconPaths.linkBorder,
                                            width: 34,
                                            height: 34,
                                            fit: BoxFit.contain,
                                            color: Colors.white,
                                          ),
                                        )),
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
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        color: selectedItems.contains(index)
                                            ? Color(0xFF2960C6)
                                            : Colors.transparent,
                                      ),
                                      child: selectedItems.contains(index)
                                          ? Icon(Icons.check,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

              /// 🔹 롱 프레스 모달 표시
              if (activeItemIndex != null && modalPosition != null)
                LongPressModal(
                  imageUrl: modalImageUrl!,
                  title: modalTitle!,
                  position: modalPosition!,
                  onClose: hideLongPressModal,
                  onEdit: (newTitle) {
                    _editItemTitle(activeItemIndex!, newTitle);
                    hideLongPressModal();
                  },
                  onDelete: () {
                    _deleteSelectedItem(activeItemIndex!);
                    hideLongPressModal();
                  },
                ),

              if (!isSelecting)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 725.h,
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
                ),

              if (_showScrollBar)
                Positioned(
                  right: -10,
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

                          double scrollFraction =
                              _scrollBarPosition / maxScrollBarHeight;
                          _scrollController.jumpTo(
                            scrollFraction *
                                _scrollController.position.maxScrollExtent,
                          );

                          _showDate = true;
                        });
                      },
                      onVerticalDragEnd: (details) {
                        setState(() {
                          _showDate = false;
                        });
                      },
                      child: SizedBox(
                        width: 48.w,
                        height: maxScrollBarHeight,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: _scrollBarPosition,
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/scroll.svg',
                                ),
                                onPressed: () {},
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
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
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
