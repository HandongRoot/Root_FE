import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SelfDevelopmentPage(),
    );
  }
}

class SelfDevelopmentPage extends StatelessWidget {
  final List<Map<String, String>> contents = [
    {
      'title': '현명한 자산 관리로의 지름길',
      'url': 'youtube.com',
      'image': 'assets/image1.png', // Replace with actual image paths
    },
    {
      'title': '주식투자, 이것만 알면 된다!',
      'url': 'instagram.com',
      'image': 'assets/image2.png',
    },
    {
      'title': '일론 머스크의 시장 보는 법',
      'url': 'https://wewxad',
      'image': 'assets/image3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자기개발'),
        actions: [
          IconButton(
            icon: Icon(Icons.grid_view),
            onPressed: () {
              // Toggle view action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '찾으시는 컨텐츠 제목을 입력하세요',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.asset(content['image']!),
                      title: Text(content['title']!),
                      subtitle: Row(
                        children: [
                          Icon(Icons.link, size: 16),
                          SizedBox(width: 4),
                          Text(content['url']!, style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      trailing: Icon(Icons.more_vert),
                      onTap: () {
                        // Add functionality to open the link
                      },
                    ),
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
