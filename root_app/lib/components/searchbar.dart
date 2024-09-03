// lib/components/searchbar.dart
import 'package:flutter/material.dart';
import '../colors.dart'; // Import the colors

class CustomSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, color: AppColors.iconColor), // Use icon color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: AppColors.primaryColor, // Use primary color for the border
            ),
          ),
          filled: true,
          fillColor: AppColors.backgroundColor, // Use background color
        ),
        style: TextStyle(color: AppColors.textColor), // Use text color
      ),
    );
  }
}
