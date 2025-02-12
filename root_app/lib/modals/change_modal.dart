import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:root_app/modals/add_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangeModal extends StatefulWidget {
  final Map<String, dynamic> item;

  const ChangeModal({required this.item});

  @override
  _ChangeModalState createState() => _ChangeModalState();
}

class _ChangeModalState extends State<ChangeModal> {
  Map<String, List<Map<String, dynamic>>> categorizedItems = {};
  Set<int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  Future<void> loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    Map<String, List<Map<String, dynamic>>> groupedByCategory = {};
    for (var item in data['items']) {
      String category = item['category'];
      if (!groupedByCategory.containsKey(category)) {
        groupedByCategory[category] = [];
      }
      groupedByCategory[category]!.add(item);
    }

    setState(() {
      categorizedItems = groupedByCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    double modalHeight = 0.7.sh;
    if (modalHeight > 606.h) {
      modalHeight = 606.h;
    }

    return Container(
      color: Colors.white,
      height: modalHeight,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "취소",
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
              ),
              Text(
                "이동할 폴더 선택",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Four',
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddModal(
                      controller: TextEditingController(),
                      onSave: () {},
                    ),
                  );
                },
                icon: SvgPicture.asset(
                  IconPaths.getIcon('add_folder'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: categorizedItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.w,
                      mainAxisSpacing: 20.h,
                    ),
                    itemCount: categorizedItems.length,
                    itemBuilder: (context, index) {
                      final category = categorizedItems.keys.elementAt(index);
                      final topItems =
                          categorizedItems[category]!.take(2).toList();
                      return GestureDetector(
                        onTap: () => _toggleSelection(index),
                        child: _buildGridItem(
                          category: category,
                          topItems: topItems,
                          isSelected: selectedItems.contains(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
    });
  }

  Widget _buildGridItem({
    required String category,
    required List<Map<String, dynamic>> topItems,
    required bool isSelected,
  }) {
    return Container(
      width: 165.w,
      height: 210.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SvgPicture.asset(
                    'assets/modal_folder.svg',
                    width: 165.w,
                    height: 130.h,
                    fit: BoxFit.contain,
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 6.h),
                        for (int i = 0; i < topItems.length; i++) ...[
                          Container(
                            width: 145.w,
                            padding: EdgeInsets.all(6.r),
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: CachedNetworkImage(
                                    imageUrl: topItems[i]['thumbnail'],
                                    width: 30.w,
                                    height: 30.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    topItems[i]['title'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.sp,
                                      fontFamily: 'Four',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                category,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Five',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              Text(
                "${topItems.length} items",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          if (isSelected)
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
