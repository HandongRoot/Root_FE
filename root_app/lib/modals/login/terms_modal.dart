import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:url_launcher/url_launcher.dart';

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

void openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

void showTermsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const TermsModalContent();
    },
  );
}

class TermsModalContent extends StatefulWidget {
  const TermsModalContent({super.key});

  @override
  State<TermsModalContent> createState() => _TermsModalContentState();
}

class _TermsModalContentState extends State<TermsModalContent> {
  bool allChecked = false;
  bool agree1 = false;
  bool agree2 = false;

  void updateAllChecked(bool value) {
    HapticFeedback.selectionClick();
    if (allChecked == value) return;
    setState(() {
      allChecked = value;
      agree1 = value;
      agree2 = value;
    });
  }

  void updateIndividual(int index, bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (index == 1 && agree1 != value) agree1 = value;
      if (index == 2 && agree2 != value) agree2 = value;
      allChecked = agree1 && agree2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNextEnabled = agree1 && agree2;

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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                ),
              ],
            ),
            const SizedBox(height: 32),

            AgreeAllBox(
              isChecked: allChecked,
              onChanged: updateAllChecked,
            ),
            const SizedBox(height: 24),

            AgreementItem(
              label: '[필수] 서비스 이용약관 동의',
              isChecked: agree1,
              onChanged: (value) => updateIndividual(1, value),
              onViewPressed: () => openUrl(
                'https://lake-breath-037.notion.site/root-17fafbeda148801497a9e717309a57b4',
              ),
            ),
            const SizedBox(height: 9),
            AgreementItem(
              label: '[필수] 개인정보 수집 및 이용 동의',
              isChecked: agree2,
              onChanged: (value) => updateIndividual(2, value),
              onViewPressed: () => openUrl(
                'https://lake-breath-037.notion.site/root-17fafbeda14880f1ae1deb5c20d216d1',
              ),
            ),
            const SizedBox(height: 54),

            // ✅ 애니메이션 제거 + 스타일 분기 처리
            SizedBox(
              width: 340,
              height: 61,
              child: ElevatedButton(
                onPressed: isNextEnabled
                    ? () {
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 21),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return const Color(0xFFD2D2D2);
                    }
                    return const Color(0xFF2960C6);
                  }),
                ),
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
  }
}

class AgreeAllBox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const AgreeAllBox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
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
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                '전체 동의',
                style: TextStyle(
                  color: isChecked
                      ? const Color(0xFF000000)
                      : const Color(0xFF727272),
                  fontFamily: 'Pretendard',
                  fontSize: 16.714,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: SizedBox(
                width: 28,
                height: 28,
                child: SvgPicture.asset(
                  IconPaths.getIcon(isChecked ? 'yes_check' : 'no_check'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgreementItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onViewPressed;

  const AgreementItem({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onChanged,
    this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20, top: 6, bottom: 6),
        child: Row(
          children: [
            SvgPicture.asset(
              IconPaths.getIcon(isChecked ? 'yes' : 'no'),
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF727272),
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onViewPressed ?? () {},
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
