import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class KakaoMapAPIScreen extends StatefulWidget {
  @override
  _KakaoMapAPIScreenState createState() => _KakaoMapAPIScreenState();
}

class _KakaoMapAPIScreenState extends State<KakaoMapAPIScreen> {
  // 1. HTML 파일의 내용을 저장할 변수
  String htmlContent = "";

  @override
  void initState() {
    super.initState();
    _loadHtmlAsset();
  }

  // 2. assets 폴더에서 HTML 파일을 읽어오는 함수
  Future<void> _loadHtmlAsset() async {
    final content = await rootBundle.loadString('assets/kakao_map.html');
    setState(() {
      htmlContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (htmlContent.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Kakao Map API Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Kakao Map API")),
      body: InAppWebView(
        // 3. 'data'를 사용하여 로컬 HTML 내용을 로드합니다.
        initialUrlRequest: URLRequest(
          url: WebUri(Uri.dataFromString(
            htmlContent,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ).toString()),
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
    );
  }
}