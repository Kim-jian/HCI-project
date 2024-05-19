import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // 각 메뉴에 대한 도움말 내용을 저장하는 맵
  Map<String, String> helpContents = {
    '홈 화면': '파일 업로드 방법'
      '\n-하단의 업로드 버튼을 누르고 파일을 선택합니다.'
      '\n-파일 업로드 후에 원하는 볼륨의 크기를 저장합니다.'
      '\n-저장한 볼륨과 현재의 볼륨 크기를 비교하며 시각화된 자료로 더 완벽하게 발표 연습을 할 수 있습니다.',
    '설정 화면': '음성 - 보이스 톤 설정, 음성 템플릿 선택, 보이스 경고 시간을 설정할 수 있습니다.'
      '\n대본 - 대본 표시 모드와 , 정렬 기준을 선택 할 수 있습니다.',
    '실행 화면': '대본 표시 모드에 따라 2개중 하나를 선택할 수 있습니다.'
      '\n-재생 버튼을 통해 대본을 재생 혹은 정지할 수 있습니다. '
      '\n-상단에 바의 크기로 목표치로 설정한 음성 크기와 현재 음성 크기를 비교할 수 있습니다.'
      '\n-상단에 그림으로 목표한 대본 진행 속도와 현재 진행중인 부분을 비교할 수 있습니다.',
  };

  // 선택한 메뉴의 도움말 내용을 저장하는 변수
  String selectedHelpContent = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도움말'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 각 메뉴를 나타내는 버튼
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedHelpContent = helpContents['홈 화면']!;
                });
              },
              child: Text('홈 화면'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedHelpContent = helpContents['설정 화면']!;
                });
              },
              child: Text('설정 화면'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedHelpContent = helpContents['실행 화면']!;
                });
              },
              child: Text('실행 화면'),
            ),
            // 선택한 메뉴의 도움말 내용을 나타내는 부분
            SizedBox(height: 20),
            Text(selectedHelpContent),
          ],
        ),
      ),
    );
  }
}
