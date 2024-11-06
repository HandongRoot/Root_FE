import 'package:flutter/material.dart';
import 'package:root_app/components/main_appbar.dart';
import 'package:root_app/components/sub_appbar.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<Widget> hearts = [];
  int tapCount = 0;
  bool showImage = false;

  void _showAndFadeHeart() {
    final uniqueKey = UniqueKey();

    // Show the custom snack bar on the first tap
    if (tapCount == 0) {
      _showTopSnackBar(context, "진짜 한번만 누르게?");
    }

    setState(() {
      tapCount++;
      if (tapCount >= 10) {
        showImage = true;
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            showImage = false;
            tapCount = 0;
          });
        });
      }
    });

    setState(() {
      hearts.add(_buildAnimatedHeart(uniqueKey, tapCount));
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      setState(() {
        hearts.removeWhere((heart) => (heart.key == uniqueKey));
      });
    });
  }

  void _showTopSnackBar(BuildContext context, String message) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 50.0,
          left: MediaQuery.of(context).size.width * 0.2,
          width: MediaQuery.of(context).size.width * 0.6,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );

      overlay?.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 2), () {
        overlayEntry.remove();
      });
    });
  }

  Widget _buildAnimatedHeart(Key key, int count) {
    return Center(
      key: key,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 800),
        child: Transform.scale(
          scale: 1.0 + count * 0.15,
          child: Icon(
            Icons.favorite,
            size: 80,
            color: Colors.red.withOpacity(0.8),
          ),
        ),
        onEnd: () {
          setState(() {
            hearts.remove(key);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SubAppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showAndFadeHeart,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '한잔해하려면 여기 눌러.\n일단  한번만 누르고 생각해',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/image.png',
                fit: BoxFit.cover,
              ),
            ],
          ),
          ...hearts,
          if (showImage)
            Center(
              child: Image.asset('assets/image2.png'),
            ),
        ],
      ),
    );
  }
}
