import 'package:flutter/material.dart';
import '../gallery.dart';
import '../home.dart';
import '../styles/colors.dart';

class HomeNavigation extends StatefulWidget {
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final PageController _navController = PageController();
  int _currentIndex = 0; // Track the selected index for navigation
  bool _isNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    // Listen for page changes and update `_currentIndex`
    _navController.addListener(() {
      setState(() {
        _currentIndex = _navController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _navController.dispose(); // Clean up the controller to prevent memory leaks
    super.dispose();
  }

  void _onScrollDirectionChange(bool isScrollingUp) {
    setState(() {
      _isNavBarVisible = isScrollingUp; // Show navbar on upward scroll
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: PageView(
              controller: _navController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Gallery(onScrollDirectionChange: _onScrollDirectionChange),
                HomePage(onScrollDirectionChange: _onScrollDirectionChange),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedOpacity(
              opacity: _isNavBarVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: CustomNavigationBar(
                navController: _navController,
                currentIndex: _currentIndex,
                onItemTapped: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _navController.jumpToPage(index);
                },
              ),
            ),
          ),
        ],
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
      width: 350,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.photo_library,
                  color: currentIndex == 0 ? AppColors.iconColor : Colors.grey,
                  size: 28,
                ),
                onPressed: () => onItemTapped(0),
              ),
              Text(
                '전체',
                style: TextStyle(
                  color: currentIndex == 0 ? AppColors.iconColor : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.folder,
                  color: currentIndex == 1 ? AppColors.iconColor : Colors.grey,
                  size: 28,
                ),
                onPressed: () => onItemTapped(1),
              ),
              Text(
                '폴더',
                style: TextStyle(
                  color: currentIndex == 1 ? AppColors.iconColor : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
