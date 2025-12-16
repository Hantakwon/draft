import 'package:flutter/material.dart';

class MyPage extends StatefulWidget { // 동적
  // 생성자
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MypageState();
}

class _MypageState extends State<MyPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBar(context),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}

// 상단 바
Widget _buildAppBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("이름"),
      Text("마이페이지"),
      Row(
          children: [
            IconButton(
              onPressed: () async {

              },
              icon: Icon(Icons.alarm,size: 30,

              ),
            ),
            IconButton(
              onPressed: () async {

              },
              icon: Icon(Icons.person,size: 30,

              ),
            )
        ]
      )
    ],
  );
}
