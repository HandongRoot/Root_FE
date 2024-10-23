import 'package:flutter/material.dart';
import 'home.dart';
import 'gallery.dart';
import 'components/navigationbar.dart';

class HomeNavigation extends StatefulWidget {
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final PageController _navController =
      PageController(); // Controller to handle nav navigation
  int _currentIndex = 0; // Tracks the currently selected index
  bool _isNavBarVisible = true; // 네비게이션 바 가시성 여부

  @override
  void dispose() {
    _navController
        .dispose(); // memeory leak 이랑 불필요한 리소스 안쓰기위해 widget ㅃㅃ 할때 같이 지워줌
    super.dispose();
  }

  void _onScrollDirectionChange(bool isScrollingUp) {
    setState(() {
      _isNavBarVisible = isScrollingUp; // 위로 스크롤 시 네비게이션 바 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _navController, // Ensure PageView is in a Stack
            children: [
              HomePage(onScrollDirectionChange: _onScrollDirectionChange),
              Gallery(onScrollDirectionChange: _onScrollDirectionChange),
            ],
          ),
          // 네비게이션 바의 위치는 고정하고 AnimatedOpacity로 투명도 애니메이션 추가
          Positioned(
            bottom: 21,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedOpacity(
              opacity: _isNavBarVisible ? 1.0 : 0.0, // 가시성에 따라 투명도 변경
              duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
              child: CustomNavigationBar(
                navController:
                    _navController, // NavController => CustomNavigationBar
                currentIndex: _currentIndex, // 선택된 index navigation bar 으로 넘기기
              ),
            ),
          ),
        ],
      ),
    );
  }
}
