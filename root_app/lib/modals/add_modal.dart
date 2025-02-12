import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styles/colors.dart';

class AddModal extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const AddModal({
    Key? key,
    required this.controller,
    required this.onSave,
  }) : super(key: key);

  @override
  _AddModalState createState() => _AddModalState();
}

class _AddModalState extends State<AddModal> {
  bool isTextEntered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.clear();

    widget.controller.addListener(() {
      setState(() {
        isTextEntered = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      backgroundColor: AppColors.primaryColor,
      child: Container(
        width: 270.w,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Column(
              children: [
                Text(
                  "새로운 폴더",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontFamily: 'Five',
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  "새로운 폴더의 제목을 입력해주세요.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'Four',
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Center(
                  child: SizedBox(
                    width: 232.w,
                    height: 26.h,
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        hintText: "제목",
                        hintStyle:
                            TextStyle(fontSize: 13.sp, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10.0.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.buttonColor,
                      ),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
            Divider(height: 0.5.h, color: AppColors.buttonDividerColor),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 42.5.h,
                      alignment: Alignment.center,
                      child: Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: 'Four',
                          color: Color(0xFF007AFF),
                          height: 22.h / 17.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5.w,
                  height: 42.5.h,
                  color: AppColors.buttonDividerColor,
                ),
                Expanded(
                  child: InkWell(
                    onTap: isTextEntered
                        ? () {
                            widget.onSave();
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                    child: Container(
                      height: 42.5.h,
                      alignment: Alignment.center,
                      child: Text(
                        "저장",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: 'Four',
                          color: isTextEntered
                              ? AppColors.secondaryColor
                              : AppColors.accentColor.withOpacity(0.5),
                          height: 22.h / 17.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
