import 'package:flutter/material.dart';
import '../components/appbar.dart';
import '../components/searchbar.dart';
import '../components/navigationbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(),  // Use the reusable AppBar
        body: Column(
          children: [
            CustomSearchBar(),  // Use the reusable search bar
            Expanded(
              child: Stack(
                children: [
                  // Your grid or other content goes here
                  GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 10, // Number of items in your grid
                    itemBuilder: (context, index) {
                      return Card(
                        child: Center(
                          child: Text('Item $index'),
                        ),
                      );
                    },
                  ),
                  CustomNavigationBar(),  // Use the reusable stacked buttons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
