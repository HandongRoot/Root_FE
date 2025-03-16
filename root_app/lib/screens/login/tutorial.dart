import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:root_app/utils/icon_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:get/get.dart';

class GalleryTutorial extends StatefulWidget {
  @override
  _GalleryTutorialState createState() => _GalleryTutorialState();
}

class _GalleryTutorialState extends State<GalleryTutorial> {
  @override
  void initState() {
    super.initState();
    _setFirstTimeFlag();
  }

  Future<void> _setFirstTimeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // 딱 한번만
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(113, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    SvgPicture.asset(IconPaths.getIcon('t1'),
                        fit: BoxFit.contain),
                    Spacer(),
                    SvgPicture.asset(IconPaths.getIcon('t2'),
                        fit: BoxFit.contain),
                    Spacer(),
                    SvgPicture.asset(IconPaths.getIcon('t3'),
                        fit: BoxFit.contain),
                  ],
                )),
            /*
            ElevatedButton(
              onPressed: () =>
                  Get.offNamed('/'), // ✅ Move to Main Page (NavBar)
              child: Text("Continue"),
            )
            */
          ],
        ),
      ),
    );
  }
}
