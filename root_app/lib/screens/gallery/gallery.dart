import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';
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
    loadContents();
  }

  // API SERVICE

  Future<void> loadContents() async {
    try {
      contents = await ApiService.getAllContents(widget.userId);
      setState(() {});
    } catch (e) {
      print("❌ Error loading contents: $e");
    }
  }

  void _renameContent(int index, String newTitle) async {
    final content = contents[index];
    final String contentId = content['id'].toString();

    setState(() {
      contents[index] = Map<String, dynamic>.from(content)
        ..['title'] = newTitle;
    });

    final success =
        await ApiService.renameContent(widget.userId, contentId, newTitle);
    if (!success) {
      print("❌ Failed to rename content.");
      setState(() {
        contents[index] = content; // 실패하면 OG title
      });
    }
  }

  Future<void> deleteContent(int index) async {
    final content = contents[index];
    final contentId = content['id'].toString();
    final success = await ApiService.deleteContent(widget.userId, contentId);
    if (success) {
      contents.removeAt(index);
      setState(() {});
    }
  }

  // 선택된 아이템 삭제
  void _deleteSelectedContents() async {
    final List<String> contentIds = selectedContents
        .map((index) => contents[index]['id'].toString())
        .toList();

    // 낙관적업뎃
    setState(() {
      contents.removeWhere(
          (content) => contentIds.contains(content['id'].toString()));
      selectedContents.clear();
      isSelecting = false;
    });
    widget.onSelectionModeChanged(false);

    final allSuccess =
        await ApiService.deleteSelectedContents(widget.userId, contentIds);

    if (!allSuccess) {
      print("❌ 몇개 실패 "); // refresh maybe 몰루
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
              onDelete: () async {
                if (activeContentIndex != null) {
                  await deleteContent(activeContentIndex!);
                  hideLongPressModal();
                }
              }),
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
                    onDelete: () async {
                      if (activeContentIndex != null) {
                        await deleteContent(activeContentIndex!);
                        hideLongPressModal();
                      }
                    }),
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
