import 'package:flutter/material.dart';
import 'package:testing/screen/main_screen.dart';

class MapPage extends StatefulWidget {
  // 동적
  // 생성자
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapState();
}

class _MapState extends State<MapPage> {
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDateTime : _endDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? _startDateTime : _endDateTime,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDateTime = newDateTime;
          } else {
            _endDateTime = newDateTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().substring(2)}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildAppBar(context)),
      body: Stack(
        children: [
          _buildMap(context),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        toolbarHeight: 80,
                        expandedHeight: 80,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // 드래그 핸들
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // 한 줄로 표시
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      // 사용 내역 제목
                                      const Text(
                                        '사용 내역',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // 날짜/시간 선택 영역
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 시작 날짜/시간
                                            InkWell(
                                              onTap: () =>
                                                  _selectDateTime(context, true),
                                              child: Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _formatDateTime(_startDateTime),
                                                  style: const TextStyle(
                                                      fontSize: 11),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Text('~', style: TextStyle(fontSize: 12)),
                                            ),
                                            // 종료 날짜/시간
                                            InkWell(
                                              onTap: () =>
                                                  _selectDateTime(context, false),
                                              child: Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[400]!,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _formatDateTime(_endDateTime),
                                                  style: const TextStyle(
                                                      fontSize: 11),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 스크롤 가능한 리스트
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.grey[100],
                              title: Text('항목 ${index + 1}'),
                            ),
                          ),
                          childCount: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 상단 바
Widget _buildAppBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [Text("CardTrack")],
  );
}

// 지도
Widget _buildMap(BuildContext context) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    margin: const EdgeInsets.all(6),
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          },
          icon: Icon(Icons.camera, size: 30),
        ),
        IconButton(onPressed: () async {
        }, icon: Icon(Icons.chat, size: 30)),
        IconButton(
          onPressed: () async {},
          icon: Icon(Icons.download, size: 30),
        ),
        IconButton(onPressed: () async {}, icon: Icon(Icons.upload, size: 30)),
      ],
    ),
  );
}