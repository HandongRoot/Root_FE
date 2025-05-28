import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root_app/main.dart';
import 'package:root_app/modals/folder/add_new_folder_and_save_modal.dart';

class SharedModal extends StatefulWidget {
  final String sharedUrl;

  const SharedModal({Key? key, required this.sharedUrl}) : super(key: key);

  @override
  State<SharedModal> createState() => _SharedModalState();
}

class _SharedModalState extends State<SharedModal> {
  List<Map<String, dynamic>> folders = [];
  String title = '';
  String thumbnail = '';

  @override
  void initState() {
    super.initState();
    fetchFolders();
    extractMetadataFromSharedUrl();
  }

  Future<void> fetchFolders() async {
    final baseUrl = dotenv.env['BASE_URL'];
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/category/findAll'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        folders = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print("폴더 가져오기 실패: ${response.statusCode}");
    }
  }

  Future<void> extractMetadataFromSharedUrl() async {
    String? videoId = extractYouTubeId(widget.sharedUrl);
    if (videoId != null) {
      final data = await fetchYoutubeVideoData(videoId);
      setState(() {
        title = data?['title'] ?? '제목 없음';
        thumbnail = data?['thumbnail'] ?? '';
      });
    } else {
      final data = await fetchWebPageData(widget.sharedUrl);
      setState(() {
        title = data?['title'] ?? '제목 없음';
        thumbnail = data?['thumbnail'] ?? '';
      });
    }
  }

  Future<void> saveContent({int? categoryId}) async {
    final baseUrl = dotenv.env['BASE_URL'];
    final url = categoryId != null
        ? Uri.parse('$baseUrl/api/v1/content?category=$categoryId')
        : Uri.parse('$baseUrl/api/v1/content');

    final body = {
      "title": title,
      "thumbnail": thumbnail,
      "linkedUrl": widget.sharedUrl,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 콘텐츠 저장 성공!");
      Navigator.pop(context);
    } else {
      print("❌ 저장 실패: ${response.statusCode}");
    }
  }

  void _openAddNewFolderModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddNewFolderAndSaveModal(
          contentTitle: title,
          thumbnail: thumbnail,
          linkedUrl: widget.sharedUrl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Transform.translate(
                offset: Offset(-7, 0),
                child: IconButton(
                  icon: SvgPicture.asset(IconPaths.getIcon('my_x')),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 14, height: 14),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Text(
                  "저장할 위치 선택하기",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 22 / 17,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
              TextButton(
                onPressed: _openAddNewFolderModal,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 22),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "추가",
                  style: TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 22 / 13,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          folders.isEmpty
              ? Column(
                  children: [
                    SvgPicture.asset(
                      'assets/shared_empty.svg',
                      width: 50,
                      height: 52.646,
                    ),
                    SizedBox(height: 7),
                    Text(
                      '아직 생성된 폴더가 없어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFBABCC0),
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 22 / 13,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: folders.map((folder) {
                      final String folderName = folder['title'] ?? '';
                      final List<dynamic> contents =
                          folder['contentReadDtos'] ?? [];
                      final String? thumb =
                          contents.isNotEmpty ? contents[0]['thumbnail'] : null;

                      return GestureDetector(
                        onTap: () => saveContent(categoryId: folder['id']),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/ShareFolder.svg",
                                    width: 55,
                                    height: 55,
                                  ),
                                  if (thumb != null && thumb.isNotEmpty)
                                    Positioned(
                                      bottom: 6,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: CachedNetworkImage(
                                          imageUrl: thumb,
                                          width: 41,
                                          height: 41,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                folderName,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 22 / 12,
                                  fontFamily: 'Pretendard',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: double.infinity,
              height: 0.7,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF2074F4), Color(0xFF34D1FB)],
              ),
            ),
            child: ElevatedButton(
              onPressed: () => saveContent(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "전체 리스트에 저장",
                    style: TextStyle(
                      color: Color(0xFFFCFCFC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 22 / 14,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  SvgPicture.asset(
                    IconPaths.getIcon('grid'),
                    fit: BoxFit.contain,
                    width: 16,
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
