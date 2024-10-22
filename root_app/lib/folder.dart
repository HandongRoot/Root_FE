import 'package:flutter/material.dart';
import 'colors.dart';

class FolderPage extends StatelessWidget {
  final Map<String, dynamic> folder;

  FolderPage({required this.folder});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = folder['items'];

    return Scaffold(
      appBar: AppBar(
        title: Text(folder['name']),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(
            leading: Image.network(
              'https://via.placeholder.com/150', // Placeholder
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(item['title']),
            subtitle: Text('Category: ${item['category']}'),
            trailing: IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                print('Opening URL: ${item['url']}');
              },
            ),
          );
        },
      ),
    );
  }
}
