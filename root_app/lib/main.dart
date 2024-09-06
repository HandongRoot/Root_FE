import 'package:flutter/material.dart';
import 'components/appbar.dart';
import 'components/navigationbar.dart';  // Import your custom navigation bar
import 'colors.dart';  // Import your colors

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,  // Use the primary color
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.accentColor,  // Use the accent color
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,  // Use the scaffold background color
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textColor),  // Use bodyLarge for main text
          bodyMedium: TextStyle(color: AppColors.textColor),  // Use bodyMedium for medium text
          bodySmall: TextStyle(color: AppColors.textColor),  // Use bodySmall for smaller text
        ),
        appBarTheme: AppBarTheme(
          color: AppColors.primaryColor,  // Set the app bar color
          iconTheme: IconThemeData(color: AppColors.accentColor),  // Set icon color for the app bar
        ),
        iconTheme: IconThemeData(
          color: AppColors.iconColor,  // Use the icon color
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: AppColors.buttonColor,  // Use the button color
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),  // Use the reusable AppBar
      body: Column(
        children: [ // Use the reusable search bar
          Expanded(
            child: Stack(
              children: [
                // Add your grid or other content here
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 10,  // Adjust this to your needs
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(
                        child: Text('Item $index'),
                      ),
                    );
                  },
                ),
                CustomNavigationBar(),  // Use the reusable navigation bar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
