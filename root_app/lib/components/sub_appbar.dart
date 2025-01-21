import 'package:flutter/material.dart';
import '../styles/colors.dart'; // Import the app-specific color constants
import 'package:flutter_svg/flutter_svg.dart'; // For rendering SVG images

class SubAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final Function(bool)? onSelectionModeChanged;
  final VoidCallback? onDeletePressed;

  const SubAppBar({
    this.height = 56,
    this.onSelectionModeChanged,  
    this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  @override
  _SubAppBarState createState() => _SubAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SubAppBarState extends State<SubAppBar> {
  bool isSelecting = false; // 선택 모드 활성화 여부

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: 30,
                height: 22,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Row(
            children: isSelecting ? _buildSelectionActions() : _buildDefaultActions(),
          ),
        ],
      ),
    );
  }

  /// 기본 상태의 액션 버튼들 (돋보기, 선택, MY 버튼)
  List<Widget> _buildDefaultActions() {
    return [
      IconButton(
        icon: const Icon(Icons.search, color: Color(0xFF00376E)),
        onPressed: () {
          Navigator.pushNamed(context, '/search');
        },
      ),
      const SizedBox(width: 16),
      _buildSelectButton(),
      const SizedBox(width: 16),
      _buildMyButton(),
    ];
  }

  /// 선택 모드에서 보일 버튼 (삭제, 완료 버튼)
  List<Widget> _buildSelectionActions() {
    return [
      _buildDeleteButton(),
      const SizedBox(width: 12),
      _buildCompleteButton(),
    ];
  }

  /// 선택 버튼
  Widget _buildSelectButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelecting = true; // 선택 모드 활성화
        });
        widget.onSelectionModeChanged?.call(true);
      },
      child: Container(
        width: 55,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Color(0xFFE1E1E1), width: 1.2),
        ),
        alignment: Alignment.center,
        child: const Text(
          '선택',
          style: TextStyle(
            color: Color(0xFF00376E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// MY 버튼
  Widget _buildMyButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/my');
      },
      child: const Text(
        'MY',
        style: TextStyle(
          color: Color(0xFF00376E),
          fontSize: 19,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 삭제 버튼
  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () {
        if (widget.onDeletePressed != null) {
          widget.onDeletePressed!(); // onDeletePressed 콜백 실행
        }
      },
      child: Container(
        width: 55,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: const Text(
          '삭제',
          style: TextStyle(
            color: Color(0xFFDC3E45),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 완료 버튼
  Widget _buildCompleteButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelecting = false; // 선택 모드 종료
        });
        widget.onSelectionModeChanged?.call(false);
      },
      child: Container(
        width: 55,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xFFF7F7F7),
        ),
        alignment: Alignment.center,
        child: const Text(
          '완료',
          style: TextStyle(
            color: Color(0xFF00376E), // 파란색
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
