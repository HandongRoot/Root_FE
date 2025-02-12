import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';

class GalleryItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isActive;
  final bool isSelecting;
  final bool isSelected; // 추가: 선택 여부
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onOpenUrl;

  const GalleryItem({
    Key? key,
    required this.item,
    required this.isActive,
    required this.isSelecting,
    required this.isSelected, // 추가
    required this.onTap,
    required this.onLongPress,
    required this.onOpenUrl,
  }) : super(key: key);

  @override
  _GalleryItemState createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> {
  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = widget.item['thumbnail'] ?? '';
    final title = widget.item['title'] ?? 'No Title';
    final contentUrl = widget.item['linkedUrl'] ?? '#';

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.isSelecting ? null : widget.onLongPress,
      child: Stack(
        children: [
          // 이미지 표시
          CachedNetworkImage(
            imageUrl: thumbnailUrl,
            width: 128,
            height: 128,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              'assets/images/placeholder.png',
              width: 128,
              height: 128,
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/placeholder.png',
              width: 128,
              height: 128,
              fit: BoxFit.cover,
            ),
          ),
          // 아이템이 active 상태일 때 오버레이 표시
          if (widget.isActive)
            Container(
              width: 128,
              height: 128,
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 34,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'five',
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Flexible(
                    child: Center(
                      child: GestureDetector(
                        onTap: widget.onOpenUrl,
                        child: SvgPicture.asset(
                          IconPaths.linkBorder,
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // 선택 모드일 때 체크 아이콘 표시
          if (widget.isSelecting)
            Positioned(
              top: 6,
              left: 6,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: widget.isSelected
                        ? const Color(0xFF2960C6)
                        : Colors.transparent,
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
