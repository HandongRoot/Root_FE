import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROOT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Root'),
        centerTitle: true,
      ),
      body: const Gallery(),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final ScrollController _scrollController = ScrollController();
  String _currentDate = "2024년 9월 1일"; // 초기 날짜 설정
  bool _showDate = false; // 날짜 표시 여부
  bool _isDraggingScrollbar = false; // 스크롤바 드래그 여부
  double _scrollBarPosition = 0.0; // 스크롤바의 현재 위치

  final Map<int, String> datePositions = {
    0: "2024년 9월 1일",
    15: "2024년 9월 2일",
    30: "2024년 9월 3일",
    45: "2024년 9월 4일",
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    setState(() {
      // 스크롤 위치에 따라 날짜 업데이트
      double scrollFraction = _scrollController.position.pixels /
          _scrollController.position.maxScrollExtent;
      int dateIndex = (scrollFraction * datePositions.length)
          .clamp(0, datePositions.length - 1)
          .toInt();
      _currentDate = datePositions[dateIndex] ?? _currentDate;

      // 스크롤 위치에 따라 스크롤바 위치도 업데이트
      _scrollBarPosition =
          scrollFraction * (MediaQuery.of(context).size.height * 0.8);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollBarDragUpdate(DragUpdateDetails details, double maxHeight) {
    setState(() {
      // 스크롤바 위치를 업데이트
      _scrollBarPosition += details.delta.dy;
      _scrollBarPosition = _scrollBarPosition.clamp(0, maxHeight);

      // 스크롤 컨트롤러 위치도 업데이트
      double scrollFraction = _scrollBarPosition / maxHeight;
      _scrollController
          .jumpTo(scrollFraction * _scrollController.position.maxScrollExtent);

      _showDate = true;
    });
  }

  void _onScrollBarDragEnd(DragEndDetails details) {
    setState(() {
      _showDate = false; // 스크롤이 끝나면 날짜를 숨김
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height;
    final maxScrollBarHeight = sizeY * 0.8; // 스크롤바 높이 제한

    return Stack(
      children: [
        GridView.count(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          crossAxisCount: 3, // 한 줄에 3개의 이미지를 배치
          children: createGallery(),
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          padding: const EdgeInsets.all(8.0),
        ),
        // 커스텀 스크롤바
        Positioned(
          right: 10,
          top: 10,
          bottom: 10,
          child: GestureDetector(
            onVerticalDragUpdate: (details) =>
                _onScrollBarDragUpdate(details, maxScrollBarHeight),
            onVerticalDragEnd: _onScrollBarDragEnd,
            child: Container(
              width: 20,
              height: maxScrollBarHeight,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: _scrollBarPosition,
                    child: Container(
                      width: 20,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showDate)
          Positioned(
            // 스크롤바 위치에 맞춰 날짜 위치를 동기화
            right: 40,
            top: _scrollBarPosition, // 스크롤바의 위치에 맞춰 날짜가 이동
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white, // 흰 배경
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Row(
                children: [
                  Text(
                    _currentDate,
                    style: const TextStyle(
                      color: Colors.blue, // 파란색 글자
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_downward,
                    color: Colors.blue,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> createGallery() {
    List<String> urls = [
      'assets/1.jpg',
      'assets/2.jpg',
      'assets/3.jpeg',
      'assets/4.webp',
      'assets/5.jpeg',
      'assets/6.jpeg',
      'assets/7.webp',
      'assets/8.jpg',
      'assets/9.jpg',
      'assets/10.png',
      'assets/11.jpg'
    ];

    List<Widget> images = [];

    for (int i = 0; i < 60; i++) {
      images.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(urls[i % urls.length]),
            ),
          ),
        ),
      );
    }

    return images;
  }
}
