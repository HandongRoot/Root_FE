// home.dart. 애 폴더 누르면 나오는 페이지임

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/styles/colors.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:root_app/modals/rename_modal.dart';
import 'package:root_app/modals/delete_item_modal.dart';

// 우리 아이콘 쓰는용
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/icon_paths.dart';

class ContentsList extends StatefulWidget {
  final String category;

  const ContentsList({required this.category});

  @override
  _ContentsListState createState() => _ContentsListState();
}

class _ContentsListState extends State<ContentsList> {
  List<dynamic> items = [];
  List<GlobalKey> gridIconKeys = [];

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
      gridIconKeys = List.generate(items.length, (index) => GlobalKey());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 500) {
          // Only trigger if swipe is fast enough
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 300,
          leading: Row(
            children: [
              const SizedBox(width: 14),
              IconButton(
                icon: SvgPicture.asset(
                  IconPaths.getIcon('back'),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.category,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                IconPaths.getIcon('search'),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
            ),
            const SizedBox(width: 19.75),
          ],
        ),
        body: items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildGridView(),
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      // 화면 양옆 마진
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // 타일 사이 간격
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildGridItemTile(item, index);
        },
      ),
    );
  }

  Widget _buildGridItemTile(Map<String, dynamic> item, int index) {
    return InkWell(
      onTap: () async {
        final String? linkedUrl =
            item['linked_url']; // url content urlafkajsjdfaklsjdflasdj ㅋㅋㅋㅋ
        if (linkedUrl != null && linkedUrl.isNotEmpty) {
          final Uri uri = Uri.parse(linkedUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("링크를 열지 못했어요"),
              ),
            );
          }
        } else {
          // URL is null or empty hanglesr
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid URL"),
            ),
          );
        }
      },
      child: SizedBox(
        height: 165,
        width: 165,
        child: Stack(
          children: [
            // Thumbnail Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item['thumbnail'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Hamburger Icon
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                key: gridIconKeys[index],
                onPressed: () => _showOptionsModal(context, item, index),
                icon: SvgPicture.asset(
                  IconPaths.getIcon('hamburger'),
                ),
                padding: const EdgeInsets.all(11),
                constraints: const BoxConstraints(),
              ),
            ),
            // Content Title 제목
            Positioned(
              bottom: 15,
              left: 11,
              right: 11,
              child: Text(
                item['title'] ?? 'Untitled', // if null
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsModal(
      BuildContext context, Map<String, dynamic> item, int index) {
    final RenderBox? icon =
        gridIconKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (icon != null) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final Offset iconPosition =
          icon.localToGlobal(Offset.zero, ancestor: overlay);
      //modal size
      final double menuWidth = 193;
      final double menuHeight = 103;

      final double top = iconPosition.dy + icon.size.height;

      double left = iconPosition.dx;
      if (left + menuWidth > MediaQuery.of(context).size.width) {
        // 오른쪽에서 왼쪽으로 쏴
        left = MediaQuery.of(context).size.width - menuWidth - 32;
      } else if (left < 0) {
        left = 0;
      }

      final double right = MediaQuery.of(context).size.width - left - menuWidth;

      final RelativeRect position = RelativeRect.fromLTRB(
        left,
        top,
        right > 0 ? right : 0,
        MediaQuery.of(context).size.height - top - menuHeight,
      );

      showMenu<String>(
              context: context,
              position: position,
              items: <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'rename',
                  height: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("정보 제목 변경"),
                        SvgPicture.asset(IconPaths.rename),
                      ],
                    ),
                  ),
                ),
                PopupMenuDivider(
                  height: 1.0,
                ),
                PopupMenuItem<String>(
                  value: 'changeCategory',
                  height: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("카테고리 위치 변경"),
                        SvgPicture.asset(IconPaths.move),
                      ],
                    ),
                  ),
                ),
                PopupMenuDivider(
                  height: 1.0,
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  height: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("콘텐츠 삭제"),
                        SvgPicture.asset(IconPaths.content_delete),
                      ],
                    ),
                  ),
                ),
              ],
              color: const Color.fromRGBO(255, 255, 255, 1.0))
          .then((value) {
        if (value == 'rename') {
          showDialog(
            context: context,
            builder: (context) => RenameModal(
              initialTitle: item['title'],
              onSave: (newTitle) {
                setState(() {
                  item['title'] = newTitle;
                });
              },
            ),
          );
        } else if (value == 'changeCategory') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // 모달자식 더 flexible 하제 만듬
            builder: (context) => ChangeModal(item: item),
          );
        } else if (value == 'delete') {
          showDialog(
            context: context,
            builder: (context) => DeleteItemModal(
              item: item,
              onDelete: () {
                setState(() {
                  items.remove(item);
                });
              },
            ),
          );
        }
      });
    }
  }

  String _getShortUrl(String url) {
    final uri = Uri.parse(url);
    return uri.host;
  }
}
