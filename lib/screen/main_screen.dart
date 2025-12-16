import 'package:flutter/material.dart';
import 'package:testing/screen/map_screen.dart';
import 'package:testing/screen/mypage_screen.dart';

class MainPage extends StatefulWidget { // 동적
  // 생성자
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainState();
}

class _MainState extends State<MainPage> {

  int _selectedIndex = 0;

  // 탭 화면 위젯 리스트
  List<Widget> _widgetList = [
    MyPage(),
    Center(child: Text('혜택', style: TextStyle(fontSize: 20),),),
    MapPage(),
    Center(child: Text('AI', style: TextStyle(fontSize: 20),),),
    Center(child: Text('회원정보 수정', style: TextStyle(fontSize: 20),),),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _widgetList.elementAt(_selectedIndex),
        // 탭바를 아래에 위치
        bottomNavigationBar: BottomNavigationBar(
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '마이'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: '혜택'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '지도'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '회원정보 수정'),
          ],
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: (index){
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
    );
  }
}