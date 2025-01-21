import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoveToFolderModal extends StatelessWidget {
  final List<Map<String, dynamic>> selectedItems;
  final Map<String, List<Map<String, dynamic>>> categorizedItems;
  final Function(String) onMove;

  const MoveToFolderModal({
    Key? key,
    required this.selectedItems,
    required this.categorizedItems,
    required this.onMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 모달 제목
          Text(
            "폴더로 이동하기",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),

          // 선택된 콘텐츠 개수 표시
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: selectedItems.first['thumbnail'],
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    Image.asset('assets/image.png', width: 40, height: 40),
              ),
              SizedBox(width: 10),
              Text(
                "${selectedItems.length}개의 콘텐츠",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 15),

          // 폴더 목록 표시
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: categorizedItems.length,
              itemBuilder: (context, index) {
                final category = categorizedItems.keys.elementAt(index);
                final topItems = categorizedItems[category]!.take(2).toList();

                return GestureDetector(
                  onTap: () {
                    onMove(category);
                    Navigator.pop(context); // 모달 닫기
                  },
                  child: FolderWidget(category: category, topItems: topItems),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FolderWidget extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> topItems;

  const FolderWidget({Key? key, required this.category, required this.topItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/folder.png', width: 90, height: 80),
            Positioned(
              top: 25,
              child: Column(
                children: topItems
                    .map((item) => Container(
                          width: 75,
                          height: 30,
                          margin: EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              item['title'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          category,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
