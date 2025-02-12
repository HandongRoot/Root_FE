import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/styles/colors.dart';
import 'package:root_app/modals/change_modal.dart';
import 'package:root_app/modals/rename_modal.dart';
import 'package:root_app/modals/delete_item_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          leadingWidth: 300.w,
          leading: Row(
            children: [
              SizedBox(width: 14.w),
              IconButton(
                icon: SvgPicture.asset(IconPaths.getIcon('back')),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  widget.category,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'five',
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
                fit: BoxFit.none,
              ),
              onPressed: () => Navigator.pushNamed(context, '/search'),
              padding: EdgeInsets.zero,
            ),
            SizedBox(width: 20.w),
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
      padding:
          EdgeInsets.only(left: 20.w, top: 10.h, right: 20.w, bottom: 20.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double minItemWidth = 165.0;

          int crossAxisCount = (constraints.maxWidth / minItemWidth).floor();
          crossAxisCount = crossAxisCount.clamp(2, 6);

          return GridView.builder(
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20.w,
              mainAxisSpacing: 20.h,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildGridItemTile(item, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildGridItemTile(Map<String, dynamic> item, int index) {
    return InkWell(
      onTap: () async {
        final String? linkedUrl = item['linked_url'];
        if (linkedUrl != null && linkedUrl.isNotEmpty) {
          final Uri uri = Uri.parse(linkedUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("링크를 열지 못했어요")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid URL")),
          );
        }
      },
      child: SizedBox(
        height: 165,
        width: 165,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: item['thumbnail'] ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.h,
              right: 0.w,
              child: IconButton(
                key: gridIconKeys[index],
                onPressed: () => _showOptionsModal(context, item, index),
                icon: SvgPicture.asset(IconPaths.getIcon('hamburger')),
                padding: EdgeInsets.all(11.r),
                constraints: const BoxConstraints(),
              ),
            ),
            Positioned(
              bottom: 15.h,
              left: 11.w,
              right: 11.w,
              child: Text(
                item['title'] ?? 'Untitled',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'five',
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

      final double menuWidth = 193;
      final double menuHeight = 103;
      final double top = iconPosition.dy + icon.size.height;

      double left = iconPosition.dx;
      if (left + menuWidth > MediaQuery.of(context).size.width) {
        left = MediaQuery.of(context).size.width - menuWidth - 32.w;
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
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("정보 제목 변경"),
                  SvgPicture.asset(IconPaths.rename),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(height: 1.0),
          PopupMenuItem<String>(
            value: 'changeCategory',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("카테고리 위치 변경"),
                  SvgPicture.asset(IconPaths.move),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(height: 1.0),
          PopupMenuItem<String>(
            value: 'delete',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
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
        color: Colors.white,
      ).then((value) {
        if (value == 'rename') {
          showDialog(
            context: context,
            builder: (context) => RenameModal(
              initialTitle: item['title'],
              onSave: (newTitle) => setState(() => item['title'] = newTitle),
            ),
          );
        } else if (value == 'changeCategory') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => ChangeModal(item: item),
          );
        } else if (value == 'delete') {
          showDialog(
            context: context,
            builder: (context) => DeleteItemModal(
              item: item,
              onDelete: () => setState(() => items.remove(item)),
            ),
          );
        }
      });
    }
  }
}
