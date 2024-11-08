// change_category_modal.dart
import 'package:flutter/material.dart';

class ChangeModal extends StatelessWidget {
  final Map<String, dynamic> item;

  ChangeModal({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Change Category for ${item['title']}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Add your UI for changing the category here
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle category change logic here
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
