class IconPaths {
  static const String basePath = 'assets/icons/';

  static const String content_delete = '${basePath}content_delete.svg';
  static const String gallery = '${basePath}gallery.svg';
  static const String linkBorder = '${basePath}link_border.svg';
  static const String link = '${basePath}link.svg';
  static const String move = '${basePath}move.svg';
  static const String rename = '${basePath}rename.svg';
  static const String search = '${basePath}search.svg';
  static const String back = '${basePath}back.svg';

  static const String hamburger = '${basePath}hamburger.svg';
  static const String folder = '${basePath}folder.svg';
  static const String my = '${basePath}my.svg';
  static const String my_x = '${basePath}my_x.svg';
  static const String my_logo = '${basePath}my_logo.svg';
  static const String x = '${basePath}x.svg';
  static const String add_folder = '${basePath}add_folder.svg';
  static const String select = '${basePath}select.svg';
  static const String folder_delete = '${basePath}folder_delete.svg';
  static const String rename_x = '${basePath}rename_x.svg';
  static const String filter = '${basePath}folder_select_filter.svg';
  static const String double_arrow_light = '${basePath}double_arrow_light.svg';
  static const String double_arrow_dark = '${basePath}double_arrow_dark.svg';
  static const String search_folder = '${basePath}search_folder.svg';
  static const String notfound_folder = '${basePath}notfound_folder.svg';
  static const String pencil = '${basePath}pencil.svg';
  static const String check = '${basePath}check.svg';
  static const String kakako = '${basePath}kakao.svg';
  static const String t1 = '${basePath}/tutorial/1.svg';
  static const String t2 = '${basePath}/tutorial/2.svg';
  static const String t3 = '${basePath}/tutorial/3.svg';
  static const String t4 = '${basePath}/tutorial/4.svg';

  static String getIcon(String iconName) {
    return '$basePath$iconName.svg';
  }
}

/* 사용방법!!!!!!!!!!!!!!!!!!!
다트 페이지 위에 이거 추가하기:
import 'package:flutter_svg/flutter_svg.dart';
import 'utils/icon_paths.dart';

iconbutton 으로 써야 할 때:
IconButton(
                  icon: SvgPicture.asset(
                    IconPaths.getIcon('search'),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),

그냥 아이콘으로 써야할때:
SvgPicture.asset(IconPaths.search),

*/
