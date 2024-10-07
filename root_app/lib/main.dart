import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'components/appbar.dart'; // Import the CustomAppBar
import 'components/navigationbar.dart'; // Import the CustomNavigationBar

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Set HomePage as the starting page
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Use the CustomAppBar as the AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns in the grid
            crossAxisSpacing: 16.0, // Space between columns
            mainAxisSpacing: 16.0, // Space between rows
            childAspectRatio: 3 / 2, // Aspect ratio for each grid item
          ),
          itemCount: 4, // Number of folder widgets
          itemBuilder: (context, index) {
            return FolderWidget(
              text: 'Folder $index',
              onPressed: () {
                // Add your navigation logic or functionality for folder tap
                print('Folder $index tapped');
              },
            );
          },
        ),
      ),
      bottomNavigationBar:
          CustomNavigationBar(), // Place the CustomNavigationBar here
    );
  }
}

class FolderWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const FolderWidget({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Light shadow
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.blue[100], // Example background color
            child: Center(
              child: SvgPicture.asset(
                'assets/folder.svg', // Path to your SVG image
                fit: BoxFit.fill, // Fill the entire container
              ),
            ),
          ),
        ),
      ),
    );
  }
}
