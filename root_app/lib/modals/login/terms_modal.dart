import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Root App")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showTermsModal(context);
          },
          child: const Text("약관 동의 모달 열기"),
        ),
      ),
    );
  }
}

void showTermsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.714),
            topRight: Radius.circular(15.786),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 21, 25, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목 + 닫기
              Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      '서비스 이용을 위한 이용약관 동의',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      width: 13,
                      height: 13,
                      child: SvgPicture.asset(
                        IconPaths.getIcon('my_x'),
                        width: 13,
                        height: 13,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 전체 동의 박스
              const AgreeAllBox(),
              const SizedBox(height: 16),

              // 개별 항목
              const AgreementItem(label: '서비스 이용약관 동의'),
              SizedBox(height: 9),
              const AgreementItem(label: '개인정보 수집 및 이용 동의'),

              const SizedBox(height: 24),

              // 다음 버튼
              SizedBox(
                width: 340,
                height: 61,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2960C6), // Main color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 21), // 수직 정렬용 패딩
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // 다음 단계로 이동
                  },
                  child: const Text(
                    '다음',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ✅ 전체 동의 박스
class AgreeAllBox extends StatefulWidget {
  const AgreeAllBox({super.key});

  @override
  State<AgreeAllBox> createState() => _AgreeAllBoxState();
}

class _AgreeAllBoxState extends State<AgreeAllBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        height: 61,
        padding: const EdgeInsets.symmetric(vertical: 17.643, horizontal: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(9.286),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '전체 동의',
              style: TextStyle(
                color: isChecked ? const Color(0xFF000000) : const Color(0xFF727272),
                fontFamily: 'Pretendard',
                fontSize: 16.714,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                height: 1,
              ),
            ),
            SizedBox(
              width: 28,
              height: 28,
              child: SvgPicture.asset(
                IconPaths.getIcon(isChecked ? 'yes_check' : 'no_check'),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ 개별 동의 항목
class AgreementItem extends StatefulWidget {
  final String label;
  final VoidCallback? onViewPressed;

  const AgreementItem({
    super.key,
    required this.label,
    this.onViewPressed,
  });

  @override
  State<AgreementItem> createState() => _AgreementItemState();
}

class _AgreementItemState extends State<AgreementItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isChecked = !isChecked),
      child: Padding(
        padding: const EdgeInsets.only(left: 36, right: 39, top: 6, bottom: 6),
        child: Row(
          children: [
            // 체크 아이콘
            SizedBox(
              child: SvgPicture.asset(
                IconPaths.getIcon(isChecked ? 'yes' : 'no'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),

            // 텍스트
            Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF727272),
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                height: 1,
              ),
            ),
            const Spacer(),

            // 보기 버튼
            TextButton(
              onPressed: widget.onViewPressed ?? () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '보기',
                style: TextStyle(
                  color: Color(0xFFABABAB),
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.solid,
                  decorationColor: Color(0xFFABABAB),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}