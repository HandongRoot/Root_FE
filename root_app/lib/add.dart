import 'package:flutter/material.dart';
import 'package:root_app/components/main_appbar.dart';

class AddPage extends StatelessWidget {
  //TODO: Add page 구현 해야함 낄낄 뭐있긴 했는데  .. 내가 원하는대로 안나와서 일단 회의 끝나고 다시 해야함
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(),
      body: Center(
        child: Text('Add page'),
      ),
    );
  }
}
