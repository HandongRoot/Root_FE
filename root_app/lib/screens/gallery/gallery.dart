import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:root_app/widgets/gallery_appbar.dart';
import 'package:root_app/main.dart';
import 'package:root_app/modals/gallery/delete_content_modal.dart';
import 'package:root_app/modals/gallery/long_press_modal.dart';
import 'package:root_app/screens/gallery/gallery_content.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class Gallery extends StatefulWidget {
  final Function(bool) onScrollDirectionChange;
  final Function(bool) onSelectionModeChanged;
  final Function(Set<int>, List<Map<String, dynamic>>) onContentSelected;
  final String userId;

  const Gallery({
    Key? key,
    required this.onScrollDirectionChange,
    required this.onSelectionModeChanged,
    required this.onContentSelected,
    required this.userId,
  }) : super(key: key);

  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  List<dynamic> contents = [];
  final ScrollController _scrollController = ScrollController();
  double _scrollBarPosition = 0.0;
  double _previousScrollOffset = 0.0;
  bool _showDate = false;
  String _currentDate = "2024년 9월 1일";

  bool isSelecting = false;
  Set<int> selectedContents = {};
  int? activeContentIndex;

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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          contents = data; // 📌 여기서 변형될 가능성 있음

          contents.sort((a, b) {
            DateTime dateA = DateTime.parse(a['createdDate']);
            DateTime dateB = DateTime.parse(b['createdDate']);
            return dateB.compareTo(dateA);
          });

          if (contents.isNotEmpty) {
            DateTime createdDate = DateTime.parse(contents[0]['createdDate']);
            _currentDate = DateFormat('yyyy년 M월 d일').format(createdDate);
          }
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
    }
  }

  void _renameContent(int index, String newTitle) async {
    final content = contents[index];
    final String contentId = content['id'].toString();
    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    final String endpoint = "/api/v1/content/update/title/$userId/$contentId";
    final String requestUrl = "$baseUrl$endpoint";

    // 낙관적 업데이트: UI에 즉시 반영 (타입 변환을 사용)
    setState(() {
      contents[index] = Map<String, dynamic>.from(content)
        ..['title'] = newTitle;
    });

    try {
      final response = await http.patch(
        Uri.parse(requestUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': newTitle}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 백엔드 업데이트 성공: 필요시 추가 처리
      } else {
        print("❌ 제목 변경 실패: ${response.body}");
        // 실패 시 롤백 로직 추가 가능
      }
    } catch (e) {
      print("❌ 에러 발생: $e");
      // 예외 발생 시 롤백 로직 추가 가능
    }
  }

  void _deleteSelectedContent(int index) async {
    final content = contents[index];
    final String contentId = content['id'].toString();
    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    final String endpoint = "/api/v1/content/$userId/$contentId";
    final String requestUrl = "$baseUrl$endpoint";

    setState(() {
      contents.removeAt(index);
      if (activeContentIndex == index) {
        activeContentIndex = null;
      }
    });

    try {
      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 백엔드 삭제 성공 시, 로컬 상태 업데이트
        setState(() {
          selectedContents.remove(index);
          isSelecting = false;
        });
        widget.onSelectionModeChanged(false);
      } else {
        print("❌ 삭제 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ 삭제 에러 발생: $e");
    }
  }

  void showLongPressModal(int index) {
    final content = contents[index];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Long Press Modal',
      barrierColor: Colors.white.withOpacity(0.45),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: LongPressModal(
            imageUrl: content['thumbnail'] ?? '',
            title: content['title'] ?? '',
            position: Offset.zero,
            onClose: () {
              Get.back();
            },
            onEdit: (newTitle) {
              _renameContent(index, newTitle);
            },
            onDelete: () {
              _deleteSelectedContent(index);
              Get.back();
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * animation.value,
            sigmaY: 5 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  void hideLongPressModal() {
    setState(() {
      activeContentIndex = null;
      modalPosition = null;
      modalImageUrl = null;
      modalTitle = null;
    });
  }

  // 스크롤에 따라서 navbar 사라지도록 하는 부분.
  void _onScroll() {
    if (contents.isNotEmpty) {
      double scrollOffset = _scrollController.offset;
      double contentHeight = 131.0;
      int contentsPerRow = 3;
      int firstVisibleRowIndex = (scrollOffset / contentHeight).floor();
      int firstVisibleIndex = firstVisibleRowIndex * contentsPerRow;

      if (firstVisibleIndex >= 0 && firstVisibleIndex < contents.length) {
        DateTime createdDate =
            DateTime.parse(contents[firstVisibleIndex]['createdDate']);
        String formattedDate = DateFormat('yyyy년 M월 d일').format(createdDate);
        setState(() {
          _currentDate = formattedDate;
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
        selectedContents.clear();
      }
    });
    widget.onSelectionModeChanged(selecting);
  }

  /// 아이템 선택/해제
  void toggleContentSelection(int index) {
    setState(() {
      if (selectedContents.contains(index)) {
        selectedContents.remove(index);
      } else {
        selectedContents.add(index);
      }
    });
    List<Map<String, dynamic>> selectedData = selectedContents
        .map((i) => contents[i] as Map<String, dynamic>)
        .toList();
    widget.onContentSelected(selectedContents, selectedData);
  }

  // 선택된 아이템 삭제 모달 띄우기
  void _showDeleteModal(BuildContext context) {
    if (selectedContents.isEmpty) return; //선택 항목이 없으면 return

    final List<Map<String, dynamic>> selectedFolderContents = selectedContents
        .map((index) => contents[index] as Map<String, dynamic>)
        .toList();

    showDialog(
      context: context,
      builder: (context) => DeleteContentModal(
        content: selectedFolderContents.first,
        onDelete: () => _deleteSelectedContents(),
      ),
    );
  }

  // 선택된 아이템 삭제
  void _deleteSelectedContents() async {
    // 선택된 아이템들을 백업(삭제할 아이템 리스트)
    final List<dynamic> contentsToDelete =
        selectedContents.map((index) => contents[index]).toList();
    final Set<dynamic> idsToDelete =
        contentsToDelete.map((content) => content['id']).toSet();

    // 낙관적 업데이트: UI에 즉각 반영 (로컬 상태에서 해당 아이템 제거)
    setState(() {
      contents.removeWhere((content) => idsToDelete.contains(content['id']));
      selectedContents.clear();
      isSelecting = false;
    });
    widget.onSelectionModeChanged(false);

    // 백엔드에 DELETE 요청을 보냅니다.
    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    bool allSuccess = true;

    for (final content in contentsToDelete) {
      final String contentId = content['id'].toString();
      final String endpoint = "/api/v1/content/$userId/$contentId";
      final String requestUrl = "$baseUrl$endpoint";

      try {
        final response = await http.delete(
          Uri.parse(requestUrl),
          headers: {'Content-Type': 'application/json'},
        );

        if (!(response.statusCode >= 200 && response.statusCode < 300)) {
          print("❌ 삭제 실패 for content id $contentId: ${response.body}");
          allSuccess = false;
        }
      } catch (e) {
        print("❌ 삭제 에러 for content id $contentId: $e");
        allSuccess = false;
      }
    }

    if (!allSuccess) {
      // 일부 삭제 요청이 실패한 경우, 데이터 불일치가 발생할 수 있으므로
      // 사용자에게 에러 메시지를 보여주거나, 데이터를 재동기화하는 방법을 고려해야 합니다.
      print("일부 아이템 삭제에 실패했습니다. 데이터 동기화 문제 발생 가능.");
    }
  }

  void toggleContentView(int index) {
    setState(() {
      if (activeContentIndex == index) {
        activeContentIndex = null;
      } else {
        activeContentIndex = index;
      }
    });
  }

  void clearActiveContent() {
    if (activeContentIndex != null) {
      setState(() {
        activeContentIndex = null;
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
    int contentsPerRow = (MediaQuery.of(context).size.width / 150).floor();

    ScrollPhysics scrollPhysics = contents.length <= contentsPerRow
        ? NeverScrollableScrollPhysics()
        : AlwaysScrollableScrollPhysics();

    final double maxScrollBarHeight = MediaQuery.of(context).size.height * 0.8;

    return Stack(
      children: [
        Scaffold(
          appBar: GalleryAppBar(
            isSelecting: isSelecting,
            onSelectionModeChanged: toggleSelectionMode,
            onDeletePressed: () => _showDeleteModal(context),
            onClearActiveContent: clearActiveContent,
          ),
          body: Stack(
            children: [
              contents.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      controller: _scrollController,
                      physics: scrollPhysics,
                      padding: EdgeInsets.only(
                          top: 7, left: 0, right: 0, bottom: 130),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 1,
                      ),
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        final content = contents[index];
                        return GalleryContent(
                          key: ValueKey(content['id']),
                          content: content,
                          isActive: activeContentIndex == index,
                          isSelecting: isSelecting,
                          isSelected: selectedContents.contains(index),
                          onTap: () {
                            if (isSelecting) {
                              toggleContentSelection(index);
                            } else {
                              toggleContentView(index);
                            }
                          },
                          onLongPress: () => showLongPressModal(index),
                          onOpenUrl: () =>
                              _openUrl(content['linkedUrl'] ?? '#'),
                        );
                      },
                    ),

              /// 🔹 롱 프레스 모달 표시
              if (activeContentIndex != null && modalPosition != null)
                LongPressModal(
                  imageUrl: modalImageUrl!,
                  title: modalTitle!,
                  position: modalPosition!,
                  onClose: hideLongPressModal,
                  onEdit: (newTitle) {
                    _renameContent(activeContentIndex!, newTitle);
                    hideLongPressModal();
                  },
                  onDelete: () {
                    _deleteSelectedContent(activeContentIndex!);
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
              if (_scrollController.hasClients &&
                  _scrollController.position.maxScrollExtent > 0 &&
                  _showScrollBar)
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
                        fontFamily: 'Four',
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
