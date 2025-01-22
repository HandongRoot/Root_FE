// home.dart. 애 폴더 누르면 나오는 페이지임

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/styles/colors.dart';
import 'package:root_app/utils/url_converter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:root_app/modals/modify_modal.dart';
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
        leadingWidth: 300, // 폴더 이름
        leading: Row(
          children: [
            const SizedBox(width: 20), // left
            // Prevent From looking like a button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.appBarPrimaryColor,
              ),
            ),
            const SizedBox(width: 20), // Space between icon and folder name
            Expanded(
              child: Text(
                widget.category,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Pretendard',
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
              height: 24.0,
              width: 24.0,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        childAspectRatio: 0.8, // Adjust aspect ratio for stack layout
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItemTile(item, index);
      },
    );
  }

  Widget _buildGridItemTile(Map<String, dynamic> item, int index) {
    return Stack(
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
        // Hamburger menu icon
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            key: gridIconKeys[index],
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _showOptionsModal(context, item, index),
          ),
        ),
        // Content title
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Text(
            item['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54, // Optional background for text
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

      // Calculate relative position for menu within screen bounds
      final RelativeRect position = RelativeRect.fromLTRB(
        iconPosition.dx,
        iconPosition.dy + icon.size.height,
        MediaQuery.of(context).size.width - iconPosition.dx - icon.size.width,
        0,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            value: 'modify',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("정보 제목 변경"),
                SvgPicture.asset(IconPaths.rename),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'changeCategory',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("카테고리 위치 변경"),
                SvgPicture.asset(IconPaths.move),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("콘텐츠 삭제"),
                SvgPicture.asset(IconPaths.delete),
              ],
            ),
          ),
        ],
        color: Color.fromARGB(255, 243, 243, 243),
      ).then((value) {
        if (value == 'modify') {
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
