import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';

class GalleryContent extends StatefulWidget {
  final Map<String, dynamic> content;
  final bool isActive;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onOpenUrl;

  const GalleryContent({
    Key? key,
    required this.content,
    required this.isActive,
    required this.isSelecting,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onOpenUrl,
  }) : super(key: key);

  @override
  _GalleryContentState createState() => _GalleryContentState();
}

class _GalleryContentState extends State<GalleryContent> {
  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = widget.content['thumbnail'] ?? '';
    final title = widget.content['title'] ?? 'No Title';

    return LayoutBuilder(
      builder: (context, constraints) {
        // 그리드 셀의 가로 길이를 가져옵니다.
        double cellSize = constraints.maxWidth;
        // 기본 디자인 기준 128에 대한 스케일 팩터 계산
        double scaleFactor = cellSize / 128.0;

        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.isSelecting ? null : widget.onLongPress,
          child: Stack(
            children: [
              // 이미지 표시 (반응형 크기로 변경)
              CachedNetworkImage(
                imageUrl: thumbnailUrl,
                width: cellSize,
                height: cellSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  'assets/images/placeholder.png',
                  width: cellSize,
                  height: cellSize,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  width: cellSize,
                  height: cellSize,
                  fit: BoxFit.cover,
                ),
              ),
              // active 상태일 때 오버레이
              if (widget.isActive)
                Container(
                  width: cellSize,
                  height: cellSize,
                  color: Colors.black.withOpacity(0.6),
                  padding: EdgeInsets.all(10 * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 34 * scaleFactor,
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scaleFactor,
                            fontFamily: 'Five',
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 35 * scaleFactor),
                      Flexible(
                        child: Center(
                          child: GestureDetector(
                            onTap: widget.onOpenUrl,
                            child: SvgPicture.asset(
                              IconPaths.linkBorder,
                              width: 34 * scaleFactor,
                              height: 34 * scaleFactor,
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
                  top: 6 * scaleFactor,
                  left: 6 * scaleFactor,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      width: 20 * scaleFactor,
                      height: 20 * scaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2 * scaleFactor),
                        color: widget.isSelected
                            ? const Color(0xFF2960C6)
                            : Colors.transparent,
                      ),
                      child: widget.isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 14 * scaleFactor)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}