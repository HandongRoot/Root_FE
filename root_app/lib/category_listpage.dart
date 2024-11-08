import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/svg.dart';
import 'package:root_app/components/main_appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/components/sub_appbar.dart';
import 'package:root_app/utils/url_converter.dart';
import 'package:url_launcher/url_launcher.dart';

// home 에서 폴더 누르면 여기에 category 안에 contents 다 나옴
class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> items = [];
  bool isGridView = true; // 그리드 리스트 와리가리

  @override
  void initState() {
    super.initState();
    loadItemsByCategory();
  }

  Future<void> loadItemsByCategory() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    setState(() {
      items = data['items']
          .where((item) => item['category'] == widget.category)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubAppBar(),
      body: Column(
        children: [
          // category 이름이랑 toggle button 들ㅇ가는 row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // 그리드 리스트 와리가리 버튼 여기있다.
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.grid_view_rounded),
                      color: isGridView
                          ? const Color.fromRGBO(41, 96, 198, 1)
                          : Colors.grey,
                      onPressed: () {
                        setState(() {
                          isGridView = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_list_rounded),
                      color: isGridView
                          ? Colors.grey
                          : const Color.fromRGBO(41, 96, 198, 1),
                      onPressed: () {
                        setState(() {
                          isGridView = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // contents 여기 쫘라랅
          Expanded(
            child: items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : isGridView
                    ? GridView.builder(
                        itemCount: items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildGridItemTile(item);
                        },
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildListItemTile(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemTile(Map<String, dynamic> item) {
    return Column(
      children: [
        Container(
          width: 344,
          height: 118,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item['thumbnail'],
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/image.png',
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(item['linked_url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          print("Could not launch ${item['linked_url']}");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromRGBO(41, 96, 198, 1),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icon_link.svg',
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getShortUrl(item['linked_url']),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(41, 96, 198, 1),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

// 말 그대로  그리드... 타일 하나 예
  Widget _buildGridItemTile(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item['thumbnail'],
              height: 138,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset(
                'assets/image.png',
                height: 138,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            item['title'],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(item['linked_url']);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                print("Could not launch ${item['linked_url']}");
              }
            },
            child: Container(
              width: 137,
              height: 30,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromRGBO(41, 96, 198, 1),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/icon_link.svg',
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getShortUrl(item['linked_url']),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(41, 96, 198, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// url 어디건지 고냥 짧개 만들어주는놈.
  String _getShortUrl(String url) {
    final uri = Uri.parse(url);
    return uri.host; // 도메인만 return 함 (예. youtu.be)
  }
}
