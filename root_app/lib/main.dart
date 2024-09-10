import 'package:flutter/material.dart';
import 'gallery.dart' as gallery;

void main() {
  gallery.main();
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Root',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ROOT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Action for adding a new folder
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: '자료 제목으로 검색하세요', // Placeholder text in Korean
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Folder Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double folderWidth = (constraints.maxWidth - 32) / 2;
                  double folderHeight = folderWidth * 0.75;

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: folderWidth /
                        (folderHeight + 40), // Adjusted to account for labels
                    children: [
                      FolderItem(
                        name: '노래',
                        count: 5,
                        width: folderWidth,
                        height:
                            folderHeight + 40, // Include space for the label
                      ), // Song in Korean
                      FolderItem(
                        name: '자기개발',
                        count: 10,
                        width: folderWidth,
                        height:
                            folderHeight + 40, // Include space for the label
                      ), // Self-Development in Korean
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FolderItem extends StatelessWidget {
  final String name;
  final int count;
  final double width;
  final double height;

  FolderItem(
      {required this.name,
      required this.count,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FolderClipper(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue[100], // Lighter color for the folder
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(2, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(), // Pushes the labels to the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis, // Avoid text overflow
                ),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  overflow: TextOverflow.ellipsis, // Avoid text overflow
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class FolderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double flapHeight = size.height * 0.2; // Height of the folder tab
    double flapWidth = size.width * 0.6; // Width of the folder tab

    // Start at the top-left corner of the folder
    path.moveTo(0, flapHeight);

    // Draw the left side of the folder
    path.lineTo(0, size.height);

    // Draw the bottom side of the folder
    path.lineTo(size.width, size.height);

    // Draw the right side of the folder
    path.lineTo(size.width, flapHeight);

    // Draw the top right of the folder tab
    path.lineTo(flapWidth + 10, flapHeight);

    // Draw the slanted edge of the tab
    path.lineTo(flapWidth, 0);

    // Draw the top left of the tab
    path.lineTo(10, 0);

    // Complete the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
