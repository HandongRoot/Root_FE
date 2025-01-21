import 'package:flutter/material.dart';
import '../gallery.dart';
import '../album.dart';
import '../styles/colors.dart';

class HomeNavigation extends StatefulWidget {
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final PageController _navController = PageController();
  int _currentIndex = 0;
  bool _isNavBarVisible = true;
  bool _isSelecting = false; // 선택 모드 여부
  Set<int> selectedItems = {};

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

  void _onScrollDirectionChange(bool isScrollingUp) {
    setState(() {
      _isNavBarVisible = isScrollingUp;
    });
  }

  /// 선택 모드가 변경될 때 호출됨
  void _onSelectionModeChanged(bool selecting) {
    setState(() {
      _isSelecting = selecting;
      if (!selecting) selectedItems.clear();
    });
  }

  void _onItemSelected(Set<int> newSelection) {
    setState(() {
      selectedItems = newSelection;
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
                  onScrollDirectionChange: _onScrollDirectionChange,
                  onSelectionModeChanged:
                      _onSelectionModeChanged, // 선택 모드 변경 콜백 전달
                  onItemSelected: _onItemSelected,
                ),
                HomePage(onScrollDirectionChange: _onScrollDirectionChange),
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
      onItemTapped: (index) {
        setState(() {
          _currentIndex = index;
        });
        _navController.jumpToPage(index);
      },
    );
  }

  /// 선택 모드일 때 표시할 "폴더로 이동" 버튼 (항상 떠 있도록 고정)
  Widget _buildFolderMoveButton() {
    bool hasSelection = selectedItems.isNotEmpty;

    return Center(
      child: Container(
        width: 144,
        height: 50,
        padding:
            EdgeInsets.symmetric(horizontal: 32, vertical: 14), // padding 적용
        decoration: BoxDecoration(
          color: Color(0xFFFCFCFC), // Light Gray 배경색
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // 그림자 효과
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center, // 가운데 정렬
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: 16,
              color: hasSelection ? Color(0xFF2960C6) : Color(0xFF727272),
            ),
            const SizedBox(width: 3),
            Text(
              '폴더로 이동',
              style: TextStyle(
                color: hasSelection
                    ? Color(0xFF2960C6)
                    : Color(0xFF727272), // Medium Gray 색상
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.69231, // 22px line-height 적용
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNavigationBar extends StatelessWidget {
  final PageController navController;
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({
    required this.navController,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 203,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(219, 221, 224, 1.0),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onItemTapped(0),
                  child: Container(
                    width: 90,
                    height: 44,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onItemTapped(1),
                  child: Container(
                    width: 90,
                    height: 44,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 17),
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
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
