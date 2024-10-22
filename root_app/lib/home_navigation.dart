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

  @override
  void dispose() {
    _navController
        .dispose(); // memeory leak 이랑 불필요한 리소스 안쓰기위해 widget ㅃㅃ 할때 같이 지워줌
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _navController, // NavController PageView 연결
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index; //index 계속 update 해주는 부분
              });
            },
            children: [
              HomePage(), // 폴더 (HomeNav)
              Gallery(), // 전체 (GalleryNav)
            ],
          ),
          Positioned(
            bottom: 21,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: CustomNavigationBar(
              navController:
                  _navController, // NavController => CustomNavigationBar
              currentIndex: _currentIndex, // 선택된 index navigation bar 으로 넘기기
            ),
          ),
        ],
      ),
    );
  }
}
