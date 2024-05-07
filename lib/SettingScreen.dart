import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedSpeaker = 'Steve Jobs'; // 초기 선택값 설정

  // 사용자가 선택할 수 있는 연설자 목록
  final List<String> speakers = ['Steve Jobs', 'Martin Luther King Jr.', 'Barack Obama', 'Winston Churchill'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ExpansionTile(
            title: Text('음성'),
            leading: Icon(Icons.record_voice_over),
            children: <Widget>[
              ListTile(
                title: Text('보이스 톤 설정'),
                onTap: () {
                  // 설정 액션을 여기에 추가하세요
                },
              ),
              ListTile(
                title: Text('음성 템플릿 선택'),
                subtitle: Text('현재 선택: $selectedSpeaker'), // 현재 선택된 템플릿을 보여줌
                onTap: () {
                  _selectSpeakerDialog(context);
                },
              ),
              ListTile(
                title: Text('보이스 경고 시간 설정'),
                onTap: () {
                  // 설정 액션을 여기에 추가하세요
                },
              ),
            ],
          ),
          ExpansionTile(
            title: Text('대본'),
            leading: Icon(Icons.description),
            children: <Widget>[
              ListTile(
                title: Text('대본 표시 설정'),
                onTap: () {
                  // 설정 액션을 여기에 추가하세요
                },
              ),
              ListTile(
                title: Text('정렬 방법 고르기'),
                onTap: () {
                  // 설정 액션을 여기에 추가하세요
                },
              ),
            ],
          ),
          ListTile(
            title: Text('구글 계정 연동'),
            leading: Icon(Icons.account_circle),
            onTap: () {
              // 설정 액션을 여기에 추가하세요
            },
          ),
        ],
      ),
    );
  }

  void _selectSpeakerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("음성 템플릿 선택"),
          content: DropdownButton<String>(
            isExpanded: true,
            value: selectedSpeaker,
            items: speakers.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSpeaker = newValue;
              });
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        );
      },
    );
  }
}