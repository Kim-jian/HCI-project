import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // 각 메뉴에 대한 도움말 내용을 저장하는 맵
  Map<String, String> helpContents = {
    '홈 화면':
    '\n파일 업로드 방법\n'
        ' - 하단의 업로드 버튼을 누르고 파일을 선택합니다.\n'
        ' - 파일은 txt 형태만 저장할 수 있습니다.\n'
        ' - 파일 업로드 후에 원하는 볼륨의 크기를 저장합니다.\n'
        ' - 저장한 볼륨과 현재의 볼륨 크기를 비교하며 시각화된 자료로 더 완벽하게 발표 연습을 할 수 있습니다.',
    '설정 화면':
    '\n음성\n'
        ' - 보이스 톤 설정\n'
        '   - 짧은 녹음을 통해 본인이 생각하는 이상적인 음의 높낮이를 저장합니다.\n'
        ' - 음성 템플릿 선택\n'
        '   - 버락 오바마, 스티브 잡스 등 유명한 연설가의 음성 템플릿으로 설정할 수 있습니다.\n'
        ' - 보이스 경고 시간\n'
        '   - 발표중 일정 시간 이상 말을 하지 않을때 경고를 띄울수 있습니다. 해당 시간을 설정할 수 있습니다.\n'

        '\n대본\n'
        ' - 대본 표시 모드\n'
        '   - 발표 연습을 할 때 대본과 키워드 중에 선택하여 표시할 수 있습니다.\n'
        ' - 키워드 수 설정\n'
        '   - 대본으로 생성되는 키워드 수를 설정할 수 있습니다.\n'
        ' - 정렬 기준\n'
        '   - 업로드 순, 최근 열람 순 중에 선택할 수 있습니다.',
    '실행 화면':
    '실행 화면.\n'
        ' - 대본 표시 모드에 따라 2개중 하나를 선택할 수 있습니다.\n'
        ' - 재생 버튼을 통해 대본을 재생 혹은 정지할 수 있습니다.\n'
        ' - 상단에 바의 크기로 목표치로 설정한 음성 크기와 현재 음성 크기를 비교할 수 있습니다.\n'
        ' - 상단에 그림으로 목표한 대본 진행 속도와 현재 진행중인 부분을 비교할 수 있습니다.',
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
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: 16.0),
                    children: _buildHelpContent(context, selectedHelpContent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHelpContent(BuildContext context, String content) {
    List<TextSpan> textSpans = [];
    List<String> lines = content.split('\n');
    for (String line in lines) {
      if (line.trim().isEmpty) {
        continue;
      } else if (line.startsWith(' - ')) {
        textSpans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium!.color),
        ));
      } else if (line.startsWith('   - ')) {
        textSpans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium!.color),
        ));
      } else {
        textSpans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium!.color),
        ));
      }
    }
    return textSpans;
  }
}
