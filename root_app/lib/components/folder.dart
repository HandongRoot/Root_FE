import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align all children to the left
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 162,
            height: 169, // Size of the folder
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Lighter shadow color
                  blurRadius: 3, // Thinner shadow
                  offset: Offset(1, 1), // Smaller offset
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(20), // Apply borderRadius to the image
              child: SvgPicture.asset(
                'assets/folder.svg', // Path to your SVG image
                fit: BoxFit.fill, // Fill the entire container
              ),
            ),
          ),
        ),
        SizedBox(height: 10), // Space between the image and the text
        Padding(
          padding: const EdgeInsets.only(left: 10.0), // Add padding to the left
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
