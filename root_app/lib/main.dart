import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isAllSelected = false;
  bool isFolderSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your logo image asset path
              width: 50,
              height: 50,
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Add edit button functionality here
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          // Grid List with Stack
          Expanded(
            child: Stack(
              children: [
                // Grid List
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 10, // Adjust based on your data
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(
                        child: Text('Item $index'),
                      ),
                    );
                  },
                ),

                // Wider Oval-shaped widget at the bottom with toggleable icons
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color to white
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.image,
                                color: isAllSelected ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  isAllSelected = true;
                                  isFolderSelected = false; // Turn off the other icon
                                });
                              },
                            ),
                            Text(
                              'All',
                              style: TextStyle(
                                color: isAllSelected ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.folder,
                                color: isFolderSelected ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  isFolderSelected = true;
                                  isAllSelected = false; // Turn off the other icon
                                });
                              },
                            ),
                            Text(
                              'Folder',
                              style: TextStyle(
                                color: isFolderSelected ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
