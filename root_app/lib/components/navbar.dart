import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../gallery.dart';
import '../folder.dart';
import '../styles/colors.dart';
import 'dart:ui';

class NavBar extends StatefulWidget {
  final String userId;

  const NavBar({Key? key, required this.userId}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final PageController _navController = PageController();
  int _currentIndex = 0;
  bool _isNavBarVisible = true;
  bool _isSelecting = false; // 선택 모드 여부
  Set<int> selectedContents = {};
  List<Map<String, dynamic>> selectedContentsData = [];
  final GlobalKey<GalleryState> galleryKey = GlobalKey<GalleryState>();

  @override
  void initState() {
    super.initState();
    _navController.addListener(() {
      setState(() {
        _currentIndex = _navController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  // 스크롤에 따라서 navbar 사라지도록 하는 법
  void _onScrollDirectionChange(bool isScrollingUp) {
    // setState(() {
    //   _isNavBarVisible = isScrollingUp;
    // });
  }

  /// 선택 모드가 변경될 때 호출됨
  void _onSelectionModeChanged(bool selecting) {
    setState(() {
      _isSelecting = selecting;
      if (!selecting) selectedContents.clear();
    });
  }

  void _onContentSelected(
      Set<int> newSelection, List<Map<String, dynamic>> selectedData) {
    setState(() {
      selectedContents = newSelection;
      selectedContentsData = selectedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(252, 252, 252, 1),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: PageView(
              controller: _navController,
              physics: _isSelecting
                  ? NeverScrollableScrollPhysics()
                  : BouncingScrollPhysics(), //선택 모드에서는 슬라이드 비활성화
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Gallery(
                  key: galleryKey,
                  userId: widget.userId,
                  onScrollDirectionChange: _onScrollDirectionChange,
                  onSelectionModeChanged: _onSelectionModeChanged,
                  onContentSelected: _onContentSelected,
                ),
                Folder(onScrollDirectionChange: _onScrollDirectionChange),
              ],
            ),
          ),
          // 네비게이션 바 변경
          if (!_isSelecting)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: AnimatedOpacity(
                  opacity: _isNavBarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _isSelecting
                      ? _buildFolderMoveButton()
                      : _buildDefaultNavBar(),
                ),
              ),
            ),

          if (_isSelecting)
            Positioned(
              bottom: 50,
              left: 123,
              right: 123,
              child: _buildFolderMoveButton(),
            ),
        ],
      ),
    );
  }

  /// 기본 네비게이션 바
  Widget _buildDefaultNavBar() {
    return CustomNavigationBar(
      navController: _navController,
      currentIndex: _currentIndex,
      onContentTapped: (index) {
        setState(() {
          _currentIndex = index;
        });
        _navController.jumpToPage(index);
      },
    );
  }

  /// 선택 모드일 때 표시할 "폴더로 이동" 버튼 (항상 떠 있도록 고정)
  Widget _buildFolderMoveButton() {
    bool hasSelection = selectedContents.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasSelection) {
          // ★ Gallery에서 선택된 콘텐츠 데이터를 NavBar로 전달받아 저장해두었다고 가정합니다.
          // 예: selectedContentsData는 List<Map<String, dynamic>> 타입이며, 선택된 콘텐츠의 전체 데이터입니다.
          // (Gallery에서 onContentSelected 콜백을 통해 NavBar에 전달하도록 수정)
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                // 다중 선택 모드이므로 ChangeModal의 contents 매개변수에 선택된 콘텐츠 목록을 전달합니다.
                child: ChangeModal(
                  contents: selectedContentsData,
                  onMoveSuccess: () {
                    galleryKey.currentState?.toggleSelectionMode(false);
                  },
                ),
              );
            },
          );
        }
      },
      child: Center(
        child: Container(
          constraints: BoxConstraints(minWidth: 100, maxWidth: 180),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC), // Light Gray 배경색
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder,
                size: 16,
                color: hasSelection
                    ? const Color(0xFF2960C6)
                    : const Color(0xFF727272),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: AutoSizeText(
                  '폴더로 이동',
                  style: TextStyle(
                    color: hasSelection
                        ? const Color(0xFF2960C6)
                        : const Color(0xFF727272),
                    fontSize: 13,
                    fontFamily: 'Four',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final PageController navController;
  final int currentIndex;
  final Function(int) onContentTapped;

  const CustomNavigationBar({
    required this.navController,
    required this.currentIndex,
    required this.onContentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
        child: Container(
          width: 203,
          height: 60,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(213, 213, 213, 0.5),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sliding background
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: currentIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: 90,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => onContentTapped(0),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(90, 44),
                        backgroundColor: Colors.transparent,
                      ).copyWith(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          Icon(
                            Icons.photo_library,
                            color: currentIndex == 0
                                ? AppColors.iconColor
                                : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '전체',
                            style: TextStyle(
                              color: currentIndex == 0
                                  ? AppColors.iconColor
                                  : Colors.white,
                              fontSize: 13,
                              fontFamily: 'Four',
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    // 투명 으로 설정한 전체-폰터 버튼 사이..
                    const SizedBox(width: 9),
                    TextButton(
                      onPressed: () => onContentTapped(1),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(90, 44),
                        padding: EdgeInsets.fromLTRB(14, 0, 16, 0),
                        backgroundColor: Colors.transparent,
                      ).copyWith(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 11),
                          Icon(
                            Icons.folder,
                            color: currentIndex == 1
                                ? AppColors.iconColor
                                : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '폴더',
                            style: TextStyle(
                              color: currentIndex == 1
                                  ? AppColors.iconColor
                                  : Colors.white,
                              fontSize: 13,
                              fontFamily: 'Four',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
