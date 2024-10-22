import 'package:flutter/material.dart';
import 'utils/url_converter.dart'; // Import the utility for URL conversion

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the utility function to get the thumbnail URL
    String youtubeUrl = 'https://youtu.be/JxS5E-kZc2s?si=ZUUXaLsFJsZKxTbn';
    String thumbnailUrl = getThumbnailFromUrl(youtubeUrl);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image List with Subtitles'),
        ),
        body: ListView(
          children: [
            // First image with an error placeholder
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://flutter.dev/assets/flutter-mono-81x100.png', // Placeholder URL
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error, // Display error icon when the image fails
                        size: 50,
                      );
                    },
                  ),
                ),
                const Text('Uploaded from a network (Flutter logo)',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            // Second image from provided URL
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://i.pinimg.com/736x/09/fa/41/09fa410e40c990bce7498f9d971838d6.jpg',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error, // Display error icon if this image fails
                        size: 50,
                      );
                    },
                  ),
                ),
                const Text('Uploaded from a network (Pinterest image)',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            // Third image from provided URL
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://img.youtube.com/vi/R7IW2eWwK-c/hqdefault.jpg',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error, // Display error icon if this image fails
                        size: 50,
                      );
                    },
                  ),
                ),
                const Text('Uploaded from YouTube thumbnail (video 1)',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            // Fourth image: Dynamically generated YouTube thumbnail
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    thumbnailUrl, // Dynamically generated thumbnail from utility function
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error, // Display error icon if this image fails
                        size: 50,
                      );
                    },
                  ),
                ),
                const Text('Dynamically generated YouTube thumbnail',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
