import 'package:flutter/material.dart';
import '../colors.dart'; // Import the app-specific color constants
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG images

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;

  const MainAppBar({this.height = 80, Key? key})
      : super(key: key); // height 는 다 패스돼서 적용죔

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _MainAppBarState extends State<MainAppBar> {
  bool isEditing = false;
  void _toggleEditing() {
    if (!isEditing) {
      Navigator.pushNamed(context, '/add');
    } else {
      setState(() {
        isEditing = !isEditing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 간격동일하게
      children: [
        Row(
          children: [
            // 로고 왼쪽 투명박스
            const SizedBox(
              width: 20,
              height: 22,
            ),
            //TODO: logo 예정이가 만들어준걸로 바꿔야함
            SvgPicture.asset(
              'assets/logo.svg',
              width: 30,
              height: 22,
              fit: BoxFit.contain,
            ),
          ],
        ),
        Row(
          children: _buildActions(), // 편집 "Action buttons"
        ),
      ],
    ));
  }

  List<Widget> _buildActions() {
    return [
      // Search button
      IconButton(
        icon: const Icon(Icons.search, color: AppColors.iconColor),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      // Add/Edit button
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //TODO: 이거 원래 편집인데 다시 한번 물어봐야할듯 좀 헷갈려영
        //TODO: 이 버튼 routing 이랑 그냥 다 다시 구현띠띠 해야함~
        child: TextButton(
          onPressed: _toggleEditing,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textColor,
            backgroundColor:
                isEditing ? AppColors.accentColor : Colors.transparent,
          ),
          child: Text(
            isEditing ? '추가' : '편집',
            style: TextStyle(
              color: isEditing ? Colors.white : AppColors.iconColor,
            ),
          ),
        ),
      ),
    ];
  }
}
