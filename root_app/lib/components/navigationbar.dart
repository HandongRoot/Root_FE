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
    _navController.dispose();
    super.dispose();
  }

  void _onScrollDirectionChange(bool isScrollingUp) {
    setState(() {
      _isNavBarVisible = isScrollingUp;
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
          // Place navigation bar at the center-bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 30), // Adjust height above bottom
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
      width: 203,
      height: 60,
      decoration: BoxDecoration(
        color:
            const Color.fromRGBO(219, 221, 224, 1.0), // Light grey background
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sliding white background
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
                        const SizedBox(width: 6), // Space between icon and text
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
                        const SizedBox(width: 17),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onItemTapped(1),
                  child: Container(
                    width: 90,
                    height: 44,
                    alignment: Alignment.center, // Center content inside button
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
                        const SizedBox(width: 6), // Space between icon and text
                        Text(
                          '폴더',
                          style: TextStyle(
                            color: currentIndex == 1
                                ? AppColors.iconColor
                                : Colors.white,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center, // Center text alignment
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
