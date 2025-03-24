import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GalleryTutorialBackground extends StatefulWidget {
  @override
  _GalleryTutorialBackgroundState createState() =>
      _GalleryTutorialBackgroundState();
}

class _GalleryTutorialBackgroundState extends State<GalleryTutorialBackground> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
