import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:root_app/modals/contentListPage/change_modal.dart';
import '../gallery.dart';
import '../folder.dart';
import '../styles/colors.dart';

class NavBar extends StatefulWidget {
  final String userId;
  final int initialTab; // 선택 초기 탭 (default: 0)
  const NavBar({Key? key, required this.userId, this.initialTab = 0})
      : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late final PageController _navController;
  int _currentIndex = 0;
  bool _isNavBarVisible = true;
  bool _isSelecting = false; // 선택 모드 여부
  Set<int> selectedContents = {};
  List<Map<String, dynamic>> selectedContentsData = [];
  final GlobalKey<GalleryState> galleryKey = GlobalKey<GalleryState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _navController = PageController(initialPage: widget.initialTab);
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

  // 스크롤 방향에 따라 네비게이션 바의 노출 여부를 제어하는 로직 (옵션)
  void _onScrollDirectionChange(bool isScrollingUp) {
    // 필요에 따라 구현
  }

  /// 선택 모드 변경 시 호출됨
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
      backgroundColor: const Color.fromRGBO(252, 252, 252, 1),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: PageView(
              controller: _navController,
              physics: _isSelecting
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
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
          if (!_isSelecting)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: AnimatedOpacity(
                  opacity: _isNavBarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildDefaultNavBar(),
                ),
              ),
            ),
          if (_isSelecting)
            Positioned(
              bottom: 50,
              left: 123.w,
              right: 123.w,
              child: _buildFolderMoveButton(),
            ),
        ],
      ),
    );
  }

  /// 기본 네비게이션 바 위젯
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

  /// 선택 모드일 때 표시할 "폴더로 이동" 버튼 위젯
  Widget _buildFolderMoveButton() {
    bool hasSelection = selectedContents.isNotEmpty;
    return GestureDetector(
      onTap: () {
        if (hasSelection) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
          constraints: BoxConstraints(minWidth: 100.w, maxWidth: 180.w),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10.r,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder,
                size: 16,
                color: hasSelection
                    ? const Color(0xFF2960C6)
                    : const Color(0xFF727272),
              ),
              SizedBox(width: 4.w),
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
      borderRadius: BorderRadius.circular(100.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
        child: Container(
          width: 203.w,
          height: 60,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(213, 213, 213, 0.5),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: currentIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: 90.w,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => onContentTapped(0),
                      style: TextButton.styleFrom(
                        minimumSize: Size(90.w, 44),
                        backgroundColor: Colors.transparent,
                      ).copyWith(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.photo_library,
                            color: currentIndex == 0
                                ? AppColors.iconColor
                                : Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6.w),
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
                          SizedBox(width: 12.w),
                        ],
                      ),
                    ),
                    SizedBox(width: 9.w),
                    TextButton(
                      onPressed: () => onContentTapped(1),
                      style: TextButton.styleFrom(
                        minimumSize: Size(90.w, 44),
                        padding: EdgeInsets.fromLTRB(14.w, 0, 16.w, 0),
                        backgroundColor: Colors.transparent,
                      ).copyWith(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 11.w),
                          Icon(
                            Icons.folder,
                            color: currentIndex == 1
                                ? AppColors.iconColor
                                : Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '폴더',
                            style: TextStyle(
                              color: currentIndex == 1
                                  ? AppColors.iconColor
                                  : Colors.white,
                              fontSize: 13,
                              fontFamily: 'Four',
                            ),
                          ),
                          SizedBox(width: 4.w),
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
