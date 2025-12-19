/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class KakaoMapAPIScreen extends StatefulWidget {
  @override
  State<KakaoMapAPIScreen> createState() => _KakaoMapAPIScreenState();
}

class _KakaoMapAPIScreenState extends State<KakaoMapAPIScreen> {
  // 1. HTML 파일의 내용을 저장할 변수
  String htmlContent = "";
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _loadHtmlAsset();
  }

  // assets 폴더에서 HTML 파일을 읽어오는 함수
  Future<void> _loadHtmlAsset() async {
    final content = await rootBundle.loadString('assets/kakao_map.html');
    setState(() {
      htmlContent = content;
    });
  }

  // 캡처 크기 선택 다이얼로그
  Future<void> _showCaptureSizeDialog() async {
    final size = await showDialog<CaptureSize>(
      context: context,
      builder: (context) => CaptureSizeDialog(),
    );

    if (size != null && webViewController != null) {
      await _captureWebView(size);
    }
  }

  // WebView 캡처 함수
  Future<void> _captureWebView(CaptureSize size) async {
    try {
      // 스토리지 권한 확인
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar('스토리지 권한이 필요합니다.');
          return;
        }
      }

      _showSnackBar('캡처 중...');

      // WebView 스크린샷 가져오기
      Uint8List? screenshot = await webViewController?.takeScreenshot(
        screenshotConfiguration: ScreenshotConfiguration(
          compressFormat: CompressFormat.PNG,
          quality: 100,
        ),
      );

      if (screenshot == null) {
        _showSnackBar('캡처 실패');
        return;
      }

      // 이미지 리사이즈 (사용자가 선택한 크기로)
      Uint8List? resizedImage = await _resizeImage(screenshot, size);

      if (resizedImage != null) {
        // 갤러리에 저장
        final result = await ImageGallerySaver.saveImage(
          resizedImage,
          quality: 100,
          name: "kakao_map_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result['isSuccess']) {
          _showSnackBar('이미지가 저장되었습니다!');
        } else {
          _showSnackBar('저장 실패');
        }
      }
    } catch (e) {
      print('캡처 에러: $e');
      _showSnackBar('캡처 중 오류 발생: $e');
    }
  }

  // 이미지 리사이즈 함수
  Future<Uint8List?> _resizeImage(Uint8List imageData, CaptureSize size) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      // 원본 이미지 크기
      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;

      int targetWidth;
      int targetHeight;

      // 사용자가 선택한 크기에 따라 타겟 크기 설정
      switch (size.type) {
        case CaptureSizeType.original:
          targetWidth = originalWidth;
          targetHeight = originalHeight;
          break;
        case CaptureSizeType.percentage:
          targetWidth = (originalWidth * size.value / 100).round();
          targetHeight = (originalHeight * size.value / 100).round();
          break;
        case CaptureSizeType.fixedWidth:
          targetWidth = size.value.toInt();
          targetHeight = (originalHeight * size.value / originalWidth).round();
          break;
        case CaptureSizeType.fixedHeight:
          targetHeight = size.value.toInt();
          targetWidth = (originalWidth * size.value / originalHeight).round();
          break;
        case CaptureSizeType.custom:
          targetWidth = size.customWidth!;
          targetHeight = size.customHeight!;
          break;
      }

      // 이미지 리사이즈
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..filterQuality = FilterQuality.high;

      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(
          0,
          0,
          originalWidth.toDouble(),
          originalHeight.toDouble(),
        ),
        Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
        paint,
      );

      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(targetWidth, targetHeight);
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('이미지 리사이즈 에러: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (htmlContent.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Kakao Map API Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildKakaoMap(
      context,
      htmlContent,
      _showCaptureSizeDialog,  // 위치 기반 인자로 수정
      (controller) {
        webViewController = controller;
      },
    );
  }
}

// KakaoMap API Screen
Widget _buildKakaoMap(
    BuildContext context,
    String htmlContent,
    VoidCallback _showCaptureSizeDialog,
    Function(InAppWebViewController) onWebViewCreated,) {
  return Scaffold(
    appBar: AppBar(title: Text("Kakao Map API")),
    body: Stack(
      children: [
        InAppWebView(
          // 3. 'data'를 사용하여 로컬 HTML 내용을 로드합니다.
          initialUrlRequest: URLRequest(
            url: WebUri(
              Uri.dataFromString(
                htmlContent,
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ).toString(),
            ),
          ),

          initialSettings: InAppWebViewSettings(
            // 1. (Android) 로컬에서 파일 접근 허용: 로컬에서 로드된 페이지가 외부 스크립트(카카오)에 접근할 수 있도록 허용
            allowFileAccess: true,
            // 2. (Android) JavaScript 허용: 이미 기본값이 true지만 명시적으로 설정
            javaScriptEnabled: true,
            // 3. (Android) 혼합 콘텐츠 허용: HTTP (카카오 스크립트) 및 HTTPS 콘텐츠를 모두 허용
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),

          // 4. (선택 사항) Flutter에서 JS 함수 호출 및 통신 설정
          onWebViewCreated: (controller) {
            // 필요하다면, 여기서 웹뷰 컨트롤러를 저장하여 JavaScript를 실행할 수 있습니다.
            // 예: controller.evaluateJavascript(source: "alert('Hello from Flutter');");
          },

          onConsoleMessage: (controller, consoleMessage) {
            // 웹뷰 내부에서 발생한 JS 콘솔 메시지 (에러 포함)를 출력
            print("WebView Console: ${consoleMessage.message}");
          },
        ),
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: _showCaptureSizeDialog,
                icon: Icon(Icons.camera, size: 30),
              ),
              IconButton(
                onPressed: () async {},
                icon: Icon(Icons.chat, size: 30),
              ),
              IconButton(
                onPressed: () async {},
                icon: Icon(Icons.download, size: 30),
              ),
              IconButton(
                onPressed: () async {},
                icon: Icon(Icons.upload, size: 30),
              ),
            ],
          ),
        ),
        _buildDraggableScroll(context),
      ],
    ),
  );
}

// 드래그 화면
Widget _buildDraggableScroll(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.5, // 기본 사이즈
    minChildSize: 0.1, // 최소 사이즈
    maxChildSize: 1.0, // 최대 사이즈
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
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              primary: false,
              expandedHeight: 60,
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: const Text(
                '테스트',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
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
      );
    },
  );
}

// 캡처 크기 설정을 위한 데이터 클래스
enum CaptureSizeType { original, percentage, fixedWidth, fixedHeight, custom }

class CaptureSize {
  final CaptureSizeType type;
  final double value;
  final int? customWidth;
  final int? customHeight;

  CaptureSize({
    required this.type,
    this.value = 100,
    this.customWidth,
    this.customHeight,
  });
}

// 캡처 크기 선택 다이얼로그
class CaptureSizeDialog extends StatefulWidget {
  @override
  State<CaptureSizeDialog> createState() => _CaptureSizeDialogState();
}

class _CaptureSizeDialogState extends State<CaptureSizeDialog> {
  CaptureSizeType selectedType = CaptureSizeType.original;
  double percentageValue = 100;
  double fixedWidthValue = 1920;
  double fixedHeightValue = 1080;
  final customWidthController = TextEditingController(text: '1920');
  final customHeightController = TextEditingController(text: '1080');

  @override
  void dispose() {
    customWidthController.dispose();
    customHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('캡처 크기 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 원본 크기
            RadioListTile<CaptureSizeType>(
              title: Text('원본 크기'),
              value: CaptureSizeType.original,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            // 비율로 조정
            RadioListTile<CaptureSizeType>(
              title: Text('비율로 조정'),
              value: CaptureSizeType.percentage,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            if (selectedType == CaptureSizeType.percentage)
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                child: Column(
                  children: [
                    Slider(
                      value: percentageValue,
                      min: 10,
                      max: 200,
                      divisions: 19,
                      label: '${percentageValue.round()}%',
                      onChanged: (value) {
                        setState(() {
                          percentageValue = value;
                        });
                      },
                    ),
                    Text('${percentageValue.round()}%'),
                  ],
                ),
              ),

            // 고정 너비
            RadioListTile<CaptureSizeType>(
              title: Text('고정 너비'),
              value: CaptureSizeType.fixedWidth,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            if (selectedType == CaptureSizeType.fixedWidth)
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                child: Column(
                  children: [
                    Slider(
                      value: fixedWidthValue,
                      min: 320,
                      max: 3840,
                      divisions: 35,
                      label: '${fixedWidthValue.round()}px',
                      onChanged: (value) {
                        setState(() {
                          fixedWidthValue = value;
                        });
                      },
                    ),
                    Text('너비: ${fixedWidthValue.round()}px (높이는 비율 유지)'),
                  ],
                ),
              ),

            // 고정 높이
            RadioListTile<CaptureSizeType>(
              title: Text('고정 높이'),
              value: CaptureSizeType.fixedHeight,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            if (selectedType == CaptureSizeType.fixedHeight)
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                child: Column(
                  children: [
                    Slider(
                      value: fixedHeightValue,
                      min: 320,
                      max: 2160,
                      divisions: 23,
                      label: '${fixedHeightValue.round()}px',
                      onChanged: (value) {
                        setState(() {
                          fixedHeightValue = value;
                        });
                      },
                    ),
                    Text('높이: ${fixedHeightValue.round()}px (너비는 비율 유지)'),
                  ],
                ),
              ),

            // 사용자 정의
            RadioListTile<CaptureSizeType>(
              title: Text('사용자 정의'),
              value: CaptureSizeType.custom,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            if (selectedType == CaptureSizeType.custom)
              Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: customWidthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '너비 (px)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: customHeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '높이 (px)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
        ElevatedButton(
          onPressed: () {
            CaptureSize size;
            switch (selectedType) {
              case CaptureSizeType.original:
                size = CaptureSize(type: CaptureSizeType.original);
                break;
              case CaptureSizeType.percentage:
                size = CaptureSize(
                  type: CaptureSizeType.percentage,
                  value: percentageValue,
                );
                break;
              case CaptureSizeType.fixedWidth:
                size = CaptureSize(
                  type: CaptureSizeType.fixedWidth,
                  value: fixedWidthValue,
                );
                break;
              case CaptureSizeType.fixedHeight:
                size = CaptureSize(
                  type: CaptureSizeType.fixedHeight,
                  value: fixedHeightValue,
                );
                break;
              case CaptureSizeType.custom:
                size = CaptureSize(
                  type: CaptureSizeType.custom,
                  customWidth: int.tryParse(customWidthController.text) ?? 1920,
                  customHeight:
                      int.tryParse(customHeightController.text) ?? 1080,
                );
                break;
            }
            Navigator.pop(context, size);
          },
          child: Text('캡처'),
        ),
      ],
    );
  }
}
*/