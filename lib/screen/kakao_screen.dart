import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:typed_data';

class KakaoMapAPIScreen extends StatefulWidget {
  @override
  State<KakaoMapAPIScreen> createState() => _KakaoMapAPIScreenState();
}

class _KakaoMapAPIScreenState extends State<KakaoMapAPIScreen> {
  // 1. HTML 파일의 내용을 저장할 변수
  String htmlContent = "";
  InAppWebViewController? webViewController;
  ScreenshotController screenshotController = ScreenshotController();

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

  // WebView 캡처 함수
  Future<void> _captureWebView() async {
    if (webViewController == null) {
      debugPrint('WebView Controller가 없습니다');
      return;
    }

    try {
      // 1. WebView 스크린샷 캡처
      Uint8List? screenshot = await webViewController!.takeScreenshot();

      if (screenshot == null) {
        debugPrint('스크린샷 캡처 실패');
        return;
      }

      // 2. 임시 파일로 저장
      final directory = await getApplicationDocumentsDirectory();
      String fileName = '캡쳐본_${DateTime.now().microsecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(screenshot);

      debugPrint('임시 저장 완료: ${file.path}');

      // 3. 갤러리에 저장
      final galleryResult = await GallerySaver.saveImage(
        file.path,
        albumName: 'KakaoMap',
      );

      debugPrint('갤러리 저장 결과: $galleryResult');

      if (galleryResult == true && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지가 갤러리에 저장되었습니다')));
      }

      // 4. 공유
      Size size = MediaQuery.of(context).size;
      await Share.shareXFiles(
        [XFile(file.path)],
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          size.width - 100,
          size.height - 100,
        ),
      );
    } catch (e) {
      debugPrint('캡처 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('캡처 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (htmlContent.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Kakao Map API Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildKakaoMap(context, htmlContent, screenshotController);
  }
}

// KakaoMap API Screen
Widget _buildKakaoMap(
  BuildContext context,
  String htmlContent,
  ScreenshotController screenshotController,
) {
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
            webViewController = controller;
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
                onPressed: _captureWebView,
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
