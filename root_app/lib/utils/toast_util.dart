import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ToastUtil {
  static void showToast(
    BuildContext context,
    String message, {
    Widget? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Container(
          width: 235.w,
          height: 50.h,
          padding: const EdgeInsets.fromLTRB(17, 13, 17, 13),
          decoration: BoxDecoration(
            color: const Color(0xFF393939),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: icon,
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFCFCFC),
                    fontSize: 14,
                    fontFamily: 'Five',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
