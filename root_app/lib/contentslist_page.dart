// home.dart. 애 폴더 누르면 나오는 페이지임

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/styles/colors.dart';
import 'package:root_app/utils/url_converter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:root_app/modals/modify_modal.dart';
import 'package:root_app/modals/delete_item_modal.dart';

class ContentsListPage extends StatefulWidget {
  final String category;

  const ContentsListPage({required this.category});

  @override
  _ContentsListPageState createState() => _ContentsListPageState();
}

class _ContentsListPageState extends State<ContentsListPage> {
  List<dynamic> items = [];
  bool isGridView = true;
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
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Column(
          children: [
            AppBar(
              backgroundColor: AppColors.primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined,
                    color: AppColors.iconColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.iconColor),
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.grid_view_rounded,
                    color: isGridView ? AppColors.iconColor : Colors.grey),
                onPressed: () {
                  setState(() {
                    isGridView = true;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.view_list_rounded,
                    color: isGridView ? Colors.grey : AppColors.iconColor),
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
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItemTile(item, index);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItemTile(item, index);
      },
    );
  }

  Widget _buildListItemTile(Map<String, dynamic> item, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: item['thumbnail'],
          width: 78,
          height: 78,
          fit: BoxFit.cover,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item['title'],
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            key: gridIconKeys[index],
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            onPressed: () => _showOptionsModal(context, item, index),
          ),
        ],
      ),
      subtitle: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(item['linked_url']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondaryColor),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/icon_link.svg', width: 12, height: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getShortUrl(item['linked_url']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItemTile(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: gridIconKeys[index],
                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                onPressed: () => _showOptionsModal(context, item, index),
              ),
              CachedNetworkImage(
                imageUrl: item['thumbnail'],
                height: 138,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 9),
              Text(
                item['title'],
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(item['linked_url']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondaryColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/icon_link.svg',
                          width: 12, height: 12),
                      const SizedBox(width: 4),
                      Text(
                        _getShortUrl(item['linked_url']),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          iconPosition.dx,
          iconPosition.dy + icon.size.height,
          iconPosition.dx + icon.size.width,
          iconPosition.dy + icon.size.height,
        ),
        items: [
          const PopupMenuItem(
            value: 'modify',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("정보 제목 변경"),
                Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'changeCategory',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("카테고리 위치 변경"),
                const Icon(Icons.category, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("콘텐츠 삭제"),
                Icon(Icons.delete, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
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
