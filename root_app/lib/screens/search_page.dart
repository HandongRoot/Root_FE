import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:root_app/services/api_services.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:root_app/main.dart';
import 'folder_contents.dart';

class Contents {
  final String title;
  final String linkedUrl;
  final String thumbnail;

  Contents({
    required this.title,
    required this.linkedUrl,
    required this.thumbnail,
  });

  factory Contents.fromJson(Map<String, dynamic> json) {
    return Contents(
      title: json['title'] ?? 'Untitled',
      linkedUrl: json['linkedUrl'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String title;

  Category({
    required this.id,
    required this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled',
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Contents> contentResults = [];
  List<Category> categoryResults = [];
  bool isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _controller.text.trim();
        if (query.isNotEmpty) {
          searchAll(query);
        } else {
          setState(() {
            contentResults.clear();
            categoryResults.clear();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> searchAll(String query) async {
    setState(() {
      isLoading = true;
    });

    final contentsFuture = ApiService.searchContents(query, userId);
    final categoriesFuture = ApiService.searchCategories(query, userId);

    final results = await Future.wait([contentsFuture, categoriesFuture]);

    setState(() {
      contentResults = results[0] as List<Contents>;
      categoryResults = results[1] as List<Category>;
      isLoading = false;
    });
  }

  // 말 그대로.. 검색한 text highlight / 색 변경
  Widget _highlightSearchText(String text, String searchText) {
    if (searchText.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 15));
    }

    // case insensitive
    final lowerText = text.toLowerCase();
    final lowerSearch = searchText.toLowerCase();
    if (!lowerText.contains(lowerSearch)) {
      return Text(text, style: TextStyle(fontSize: 15));
    }
    final startIndex = lowerText.indexOf(lowerSearch);
    final endIndex = startIndex + searchText.length;
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 15, color: Colors.black, fontFamily: 'Six'),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(color: Color(0xFF2960C6)),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  search text field 에 검색 text 오른쪽에 padding ?
    final double availableWidth = MediaQuery.of(context).size.width - 60;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 0),
          // back button
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: SvgPicture.asset(IconPaths.getIcon('back')),
              ),
            ),
          ),
        ),
        // search bar
        title: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: availableWidth,
            height: 45,
            decoration: BoxDecoration(
              color: Color(0xFFF8F8FA),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.fromLTRB(18.w, 0, 4.w, 0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '폴더나 콘텐츠의 제목을 검색해보세요!',
                hintStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Five', color: Colors.grey),
                border: InputBorder.none,
                suffixIcon: _controller.text.isNotEmpty
                    // search bar : "x" clear button
                    ? IconButton(
                        icon: SvgPicture.asset(
                          IconPaths.getIcon('x'),
                          fit: BoxFit.none,
                        ),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            contentResults.clear();
                            categoryResults.clear();
                          });
                        },
                        padding: EdgeInsets.zero,
                      )
                    : null,
              ),
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _controller.text.trim().isEmpty
              ? Center()
              // 결과 없을때 placeholder
              : (categoryResults.isEmpty && contentResults.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              IconPaths.getIcon('notfound_folder'),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "'${_controller.text.trim()}'(으)로 \n저장된 폴더나 콘텐츠가 없어요 \n다른 키워드로 검색 해볼까요?",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFBABCC0),
                                fontFamily: 'Five',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 폴더 검색 결과
                            if (categoryResults.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "폴더",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Four',
                                      color: Color(0xFF727272),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  // search result list 행태: [ 📁 folder(category)name ]
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: categoryResults.length,
                                    itemBuilder: (context, index) {
                                      final cat = categoryResults[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: InkWell(
                                          onTap: () {
                                            Get.off(() => FolderContents(
                                                  categoryId: cat.id,
                                                  categoryName: cat.title,
                                                ));
                                          },
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                IconPaths.getIcon(
                                                    'search_folder'),
                                                fit: BoxFit.contain,
                                              ),
                                              SizedBox(width: 18.w),
                                              Flexible(
                                                child: _highlightSearchText(
                                                  cat.title,
                                                  _controller.text.trim(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // 폴터 카테고리 결과랑 컨텐츠 결과 사이 간격
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            // 카테고리 검색 결과
                            if (contentResults.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "콘텐츠",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Four',
                                      color: Color(0xFF727272),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  // search result list 행태: [ 🖼️ content name ]
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: contentResults.length,
                                    itemBuilder: (context, index) {
                                      final content = contentResults[index];
                                      return Column(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              final String? linkedUrl =
                                                  content.linkedUrl;
                                              if (linkedUrl != null &&
                                                  linkedUrl.isNotEmpty) {
                                                final Uri uri =
                                                    Uri.parse(linkedUrl);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  // TODO: 예정핑 snackbar 만들어달라고하기
                                                  Get.snackbar(
                                                    '',
                                                    '',
                                                    titleText:
                                                        SizedBox.shrink(),
                                                    messageText: Text(
                                                      '링크를 열지 못했습니다',
                                                      style: TextStyle(
                                                        fontFamily: 'Four',
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    margin: EdgeInsets.all(16),
                                                    duration:
                                                        Duration(seconds: 3),
                                                  );
                                                }
                                              } else {
                                                Get.snackbar(
                                                  '',
                                                  '',
                                                  titleText: SizedBox.shrink(),
                                                  messageText: Text(
                                                    '잘못 된 URL 경로입니다',
                                                    style: TextStyle(
                                                      fontFamily: 'Four',
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  margin: EdgeInsets.all(16),
                                                  duration:
                                                      Duration(seconds: 3),
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5.h),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          content.thumbnail,
                                                      width: 45,
                                                      height: 45,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        'assets/images/placeholder.png',
                                                        width: 45,
                                                        height: 45,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 18.w),
                                                  // 검색한 text 만 색 변하도록 적용
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _highlightSearchText(
                                                            content.title,
                                                            _controller.text
                                                                .trim()),
                                                        SizedBox(height: 4.h),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 40.h),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
