import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class LongPressModal extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Offset position;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LongPressModal({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.position,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔹 배경 블러 효과
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.white.withOpacity(0.45),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(),
              ),
            ),
          ),
        ),

        /// 🔹 고정된 아이템 카드
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Container(
            width: 143,
            height: 143,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.7),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 123,
                  height: 123,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder.png',
                    width: 123,
                    height: 123,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
