import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:root_app/modals/rename_modal.dart';
import 'package:root_app/modals/delete_item_modal.dart';

class LongPressModal extends StatelessWidget {
  final String imageUrl;
  final String title;
  final Offset position;
  final VoidCallback onClose;
  final void Function(String) onEdit;
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
    // 화면 크기 가져오기
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 모달 크기 정의
    const double modalWidth = 208;
    const double modalHeight = 208 + 15 + 72; // 이미지(143) + 버튼 컨테이너(72) + 여백(15)

    // X 좌표 조정 (모달이 화면 밖으로 나가지 않도록)
    double adjustedX = (screenWidth - modalWidth) / 2;
    double adjustedY = 100;

    return Stack(
      children: [
        /// 🔹 반투명 배경 (클릭하면 닫힘)
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(
                color: Colors.white.withOpacity(0.45),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(),
                )),
          ),
        ),

        /// 🔹 조정된 모달 위치 적용
        Positioned(
          left: adjustedX,
          top: adjustedY,
          child: Column(
            children: [
              /// 🔹 이미지 + Opacity + 제목 (Stack을 사용하여 레이어 순서 조정)
              Stack(
                children: [
                  /// 🔹 배경 이미지와 gradient 오버레이를 함께 적용 (border-radius 14.545 적용)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.545),
                    child: Container(
                      width: 208,
                      height: 208,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(0, 0, 0, 0.70),
                            Color.fromRGBO(0, 0, 0, 0.70),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// 🔹 제목 텍스트 (padding 적용)
                  Positioned(
                    top: 10,
                    left: 15,
                    right: 15,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'six',
                        decoration: TextDecoration.none,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2, // 너무 길면 2줄까지만 표시
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15), // 이미지와 모달 사이 간격

              /// 🔹 수정 & 삭제 버튼 모달
              Container(
                width: 193,
                height: 72,
                padding: EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// 🔹 제목 수정 버튼
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => RenameModal(
                            initialTitle: title,
                            onSave: (newTitle) {
                              onEdit(newTitle);
                              onClose();
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "콘텐츠 제목 변경",
                                style: TextStyle(
                                  color: Color(0xFF393939),
                                  fontSize: 12,
                                  fontFamily: 'four',
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Icon(Icons.edit,
                                size: 15,
                                color: Color(0xFF393939)), // 🔹 아이콘 우측 정렬
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8),
                    Divider(color: Colors.grey[300], height: 1),
                    SizedBox(height: 8),

                    /// 🔹 콘텐츠 삭제 버튼 (텍스트 좌측 정렬, 아이콘 우측 정렬)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteItemModal(
                            item: {'title': title},
                            onDelete: () {
                              onDelete();
                              onClose();
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "콘텐츠 삭제",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontFamily: 'four',
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Icon(Icons.delete,
                                size: 15,
                                color: Colors.redAccent), // 🔹 아이콘 우측 정렬
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
      ],
    );
  }
}
