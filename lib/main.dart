import 'package:flutter/material.dart';
import 'package:testing/screen/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget { // 정적
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "제목",
      home: const MainPage(),
    );
  }
}

class MyHomePage extends StatefulWidget { // 동적
  // 생성자
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // private count 변수
  int _count = 100;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sample Code')),
        body: Column(
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          color: Colors.blue,
                          child: const Center(child: Text("이름"),)
                      ),
                    ],
                  ),
                  Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                      child: const Center(child: Text("나이"),)
                  )
                ]
              ),
            ElevatedButton(
                onPressed: (){
                  // 현재 화면 위젯 스텍 제거, 뒤로가기
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondPage())
                  );
                },
                child: const Text('second Screen 이동')
            ),
            Center(child: Row(children: [Text("이름"), Text("나이")],),),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _count--),
          tooltip: 'Increment Counter',
          child: const Icon(Icons.exposure_minus_1),
        ),
    );
  }
}

class SecondPage extends StatefulWidget { // 동적
  // 생성자
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // private count 변수
  int _count = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample Code')),
      body: Center(child: Column(
        children: [
          ElevatedButton(
              onPressed: (){
                // 현재 화면 위젯 스텍 제거, 뒤로가기
                Navigator.pop(context);
              },
              child: const Text('First Screen 이동')
          ),

        ],
      )),

      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count--),
        tooltip: 'Increment Counter',
        child: const Icon(Icons.exposure_minus_1),
      ),
    );
  }
}