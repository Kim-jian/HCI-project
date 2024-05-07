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
  String? selectedSorting = '업로드 순'; // 초기 정렬 방법 설정
  String? selectedSpeaker = 'Steve Jobs'; // 초기 선택 값 설정(템플릿)
  int playbackTime = 3; //초기 재생 시간 설정
  final List<int> playbackTimeOptions = [2, 3, 4, 5]; // 가능한 재생 시간 목록

  // 사용자가 선택할 수 있는 연설자 목록
  final List<String> speakers = ['Steve Jobs', 'Martin Luther King Jr.', 'Barack Obama', 'Winston Churchill', 'None'];

  // 사용 가능한 정렬 방법 목록
  final List<String> sortingMethods = ['업로드 순', '최근 수정 일자 순'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Example'),
      ),
      body: ListView(
        children: <Widget>[
          ExpansionTile(
            title: const Text('음성'),
            leading: const Icon(Icons.record_voice_over),
            children: <Widget>[
              ListTile(
                title: const Text('보이스 톤 설정'),
                onTap: () {
                  _showRecordingDialog(context);
                },
              ),
              ListTile(
                title: const Text('음성 템플릿 선택'),
                subtitle: Text('현재 선택: $selectedSpeaker'),
                onTap: () {
                  _selectSpeakerDialog(context);
                },
              ),
              ListTile(
                title: const Text('보이스 경고 시간 설정'),
                subtitle: Text('현재 선택: $playbackTime 초'),
                onTap: () {
                  showPlaybackTimeSettingDialog(context);
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('대본'),
            leading: const Icon(Icons.description),
            children: <Widget>[
              ListTile(
                title: const Text('대본 표시 설정'),
                onTap: () {
                  // 설정 액션을 여기에 추가하세요
                },
              ),
              ListTile(
                title: const Text('정렬 방법 고르기'),
                subtitle: Text('현재 선택: $selectedSorting'), // 현재 선택된 정렬 방법 표시
                onTap: _showSortingDialog,
              ),
            ],
          ),
          ListTile(
            title: const Text('구글 계정 연동'),
            leading: const Icon(Icons.account_circle),
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
          title: const Text("음성 템플릿 선택"),
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
                // 선택된 템플릿을 맨 앞으로 이동
                if (newValue != null && newValue != selectedSpeaker) {
                  speakers.remove(newValue);
                  speakers.insert(0, newValue);
                  selectedSpeaker = newValue;
                }
              });
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        );
      },
    );
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("정렬 방법 고르기"),
          content: DropdownButton<String>(
            isExpanded: true,
            value: selectedSorting,
            items: sortingMethods.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSorting = newValue;
              });
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        );
      },
    );
  }

  void _showRecordingDialog(BuildContext context) {
    bool isRecording = false;
    bool showPlaybackOptions = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("보이스 톤 설정"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!showPlaybackOptions)
                    Column(
                      children: [
                        Text(isRecording ? "녹음 중..." : "녹음을 시작하려면 아래 버튼을 누르세요."),
                        const SizedBox(height: 16),
                        if (!isRecording)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isRecording = true; // 녹음 시작 상태
                                //여기서 녹음 기능을 켜야함.
                              });
                            },
                            child: const Text("녹음 시작"),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isRecording = false; // 녹음 중지 상태
                                showPlaybackOptions = true; // 재생 옵션 표시
                                //여기서 녹음 중지해야함.
                              });
                            },
                            child: const Text("녹음 중지"),
                          ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Text("녹음된 음성을 들어보거나 다시 녹음하세요."),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // 실제 녹음 재생 기능을 추가해야 함
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("녹음된 음성이 재생되었습니다.")),
                            );
                          },
                          child: const Text("녹음 재생"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPlaybackOptions = false; // 재생 옵션을 숨김
                              isRecording = true; // 바로 녹음 시작 상태로 전환
                            });
                          },
                          child: const Text("다시 녹음하기"),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void showPlaybackTimeSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("보이스 경고 시간 설정"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text("녹음 재생 시간을 선택하세요:"),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: playbackTime,
                    onChanged: (int? newValue) {
                      setState(() {
                        playbackTime = newValue ?? playbackTime;
                      });
                    },
                    items: <int>[2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value 초"),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                setState(() {}); // 외부의 subtitle 업데이트
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
