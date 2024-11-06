import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SVG 이미지를 위해 추가
import 'package:root_app/components/main_appbar.dart';
import 'package:root_app/utils/url_converter.dart'; // Import the utility

// 기본 스크롤바를 숨기는 CustomScrollBehavior 정의
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child; // 기본 스크롤바를 없앰
  }
}

class Gallery extends StatefulWidget {
  final Function(bool) onScrollDirectionChange; // 스크롤 방향 변화 콜백 추가

  Gallery({required this.onScrollDirectionChange});

  @override
  _GalleryState createState() => _GalleryState();
}

//TODO: 아이콘 눌렀을때 그 줌 되는거 예..
//TODO: 사실 이거 ㅋㅋㅋㅋ 임성빈이 구현한 scroll chatGPT 한테 함성해달라해서 해준건데 일단 스크롤 height 이랑 뭐
// 이것저것 수정이 부족한 것 같아서 그거 수정해야함. 그래서 ㅋㅋ 임성빈이 만든거 chapGPT가 친절하세 주석 달아줌 ㅋㅋㅋ
class _GalleryState extends State<Gallery> {
  List<dynamic> items = []; // List to store gallery items from mock data
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러
  String _currentDate = "2024년 9월 1일"; // 스크롤 위치에 따른 날짜 표시
  bool _showDate = false; // 날짜 표시 여부
  double _scrollBarPosition = 0.0; // 스크롤바 위치 추적
  double _previousOffset = 0.0; // 스크롤의 이전 위치 저장

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener); // 스크롤 리스너 추가
    loadMockData(); // 페이지 초기화 시 mock 데이터 로드
  }

  /*
   * Loads mock data from the JSON file in the assets folder.
   */
  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    // mock 데이터로 items 리스트 업데이트
    setState(() {
      items = data['items'];
    });
  }

  /*
   * Scroll listener function to track the scroll position and adjust date and scrollbar position.
   */
  void _scrollListener() {
    if (items.isNotEmpty) {
      double scrollOffset = _scrollController.offset; // 현재 스크롤 위치 가져오기
      double itemHeight = 200.0; // 각 그리드 아이템의 대략적인 높이
      int firstVisibleIndex =
          (scrollOffset / itemHeight).floor(); // 첫 번째 보이는 아이템 인덱스 찾기

      if (firstVisibleIndex >= 0 && firstVisibleIndex < items.length) {
        // 첫 번째 보이는 아이템의 날짜로 날짜 표시 업데이트
        setState(() {
          _currentDate = items[firstVisibleIndex]['dateAdded'] ?? _currentDate;
        });
      }

      // 스크롤바 위치를 스크롤 퍼센트에 맞춰 업데이트
      double scrollFraction = _scrollController.position.pixels /
          _scrollController.position.maxScrollExtent;
      _scrollBarPosition =
          scrollFraction * (MediaQuery.of(context).size.height * 0.8);

      // 스크롤 방향을 감지하여 위젯으로 전달
      if (_scrollController.offset > _previousOffset) {
        widget.onScrollDirectionChange(false); // 아래로 스크롤
      } else {
        widget.onScrollDirectionChange(true); // 위로 스크롤
      }
      _previousOffset = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 스크롤 컨트롤러 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeY = MediaQuery.of(context).size.height; // 화면 높이
    final maxScrollBarHeight = sizeY * 0.8; // 커스텀 스크롤바의 최대 높이

    return Scaffold(
      appBar: MainAppBar(),
      // ScrollConfiguration을 사용하여 기본 스크롤바 제거
      body: ScrollConfiguration(
        behavior: CustomScrollBehavior(), // 기본 스크롤바를 없앰
        child: Stack(
          children: [
            // 그리드 뷰
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: items.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // 이거 그냥 추가해봤어 히히힣ㅎ 로딩할때 그 동그란거 나오는거야
                  : GridView.builder(
                      controller: _scrollController, // 스크롤 컨트롤러 연결
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 한 줄에 세 개의 이미지
                      ),
                      itemCount: items.length, // 총 아이템 수
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final thumbnailUrl =
                            getThumbnailFromUrl(item['url']); // 썸네일 URL 변환
                        return ImageGridItem(
                            imageUrl: thumbnailUrl); // 그리드 아이템 렌더링
                      },
                    ),
            ),
            // 커스텀 스크롤바 구현
            Positioned(
              right: 10,
              top: 10,
              bottom: 10,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _scrollBarPosition += details.delta.dy; // 스크롤바 위치 업데이트
                    _scrollBarPosition = _scrollBarPosition.clamp(
                        0, maxScrollBarHeight); // 위치 제한

                    // 스크롤바 위치에 따른 콘텐츠 스크롤
                    double scrollFraction =
                        _scrollBarPosition / maxScrollBarHeight;
                    _scrollController.jumpTo(
                      scrollFraction *
                          _scrollController.position.maxScrollExtent,
                    );

                    _showDate = true; // 스크롤 중 날짜 표시
                  });
                },
                onVerticalDragEnd: (details) {
                  setState(() {
                    _showDate = false; // 스크롤 종료 시 날짜 숨김
                  });
                },
                child: Container(
                  width: 20,
                  height: maxScrollBarHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: _scrollBarPosition,
                        child: SvgPicture.asset(
                          'assets/scroll.svg', // 스크롤바 이미지
                          width: 20,
                          height: 40,
                          fit: BoxFit.cover, // 이미지가 컨테이너에 맞도록 설정
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 스크롤 중 날짜 표시
            if (_showDate)
              Positioned(
                right: 40,
                top: _scrollBarPosition,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _currentDate, // 현재 날짜 표시
                        style: const TextStyle(
                          color: Colors.blue,
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
        ),
      ),
    );
  }
}

/*
 * 그리드의 각 아이템 - 이미지 그리드 아이템
 */
class ImageGridItem extends StatelessWidget {
  final String imageUrl; // 이미지 URL

  const ImageGridItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // 둥근 모서리
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl, // URL로부터 이미지 가져오기
        placeholder: (context, url) =>
            CircularProgressIndicator(), // 로딩 중 스피너 표시
        // ! url issue errorWidget image 으로 변경
        errorWidget: (context, url, error) => Image.asset(
          'assets/image.png', // 로컬 이미지 경로
          width: 37, // 이미지 크기 조정
          height: 37,
          fit: BoxFit.cover, // 이미지가 컨테이너에 맞도록 설정
        ),
      ),
    );
  }
}
