import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
              child: SvgPicture.asset(
                'assets/icons/tutorial.svg',
                fit: BoxFit.fill,
              ),
            ),
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
