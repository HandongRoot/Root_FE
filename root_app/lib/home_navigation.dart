import 'package:flutter/material.dart';
import 'home.dart';
import 'gallery.dart';
import 'components/navigationbar.dart';

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
      backgroundColor:
          Colors.white, // Ensures the entire screen background is white
      body: Stack(
        children: [
          Container(
            color: Colors.white, // Adds a white background behind the PageView
            child: PageView(
              controller: _navController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                HomePage(onScrollDirectionChange: _onScrollDirectionChange),
                Gallery(onScrollDirectionChange: _onScrollDirectionChange),
              ],
            ),
          ),
          // Position and animate the navigation bar with opacity
          Positioned(
            bottom: 21,
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
