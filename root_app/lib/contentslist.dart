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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,

        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 300, // 폴더 이름 길이? 뭐 그런거
        leading: Row(
          children: [
            const SizedBox(width: 20), // appbar farmost left
            // Prevent From looking like a button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                IconPaths.getIcon('back'),
              ),
            ),
            const SizedBox(width: 20), // Space between icon and folder name
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/search');
            },
            child: SvgPicture.asset(
              IconPaths.getIcon('search'),
            ),
          ),
          const SizedBox(width: 19.75),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return Padding(
      // 화면 양옆 마진
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
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
    return SizedBox(
      height: 165,
      width: 165,
      child: Stack(
        children: [
          // Thumbnail Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item['thumbnail'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay 그라데이션션션
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
          // hamburger
          Positioned(
            // hamburger icon placement and touch thing 인식
            top: 0,
            right: 0,
            child: IconButton(
              key: gridIconKeys[index],
              onPressed: () => _showOptionsModal(context, item, index),
              icon: SvgPicture.asset(
                IconPaths.getIcon('hamburger'),
              ),
              padding: EdgeInsets.all(11), // 기본 패딩값 룰루
              constraints: const BoxConstraints(), // 기본값 저리가고
            ),
          ),
          // Content title
          Positioned(
            bottom: 15,
            left: 11,
            right: 11,
            child: Text(
              item['title'],
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

      final double menuWidth = 193;
      final double menuHeight = 103;

      final double left =
          iconPosition.dx + menuWidth > MediaQuery.of(context).size.width
              ? iconPosition.dx - menuWidth
              : iconPosition.dx;
      final double top = iconPosition.dy;
      final double right = MediaQuery.of(context).size.width - left - menuWidth;

      final RelativeRect position = RelativeRect.fromLTRB(
        left > 0 ? left : 0,
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
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("정보 제목 변경"),
                SvgPicture.asset(IconPaths.rename),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'changeCategory',
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("카테고리 위치 변경"),
                SvgPicture.asset(IconPaths.move),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'delete',
            height: menuHeight / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("콘텐츠 삭제"),
                SvgPicture.asset(IconPaths.delete),
              ],
            ),
          ),
        ],
        color: const Color.fromRGBO(217, 217, 217, 1.0),
      ).then((value) {
        if (value == 'rename') {
          showDialog(
            context: context,
            builder: (context) => ModifyModal(
              initialTitle: item['title'],
              onSave: (newTitle) {
                setState(() {
                  item['title'] = newTitle;
                });
              },
            ),
          );
        } else if (value == 'changeCategory') {
          showDialog(
            context: context,
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
