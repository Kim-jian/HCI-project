import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:provider/provider.dart';
import 'SoundRecorder.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //현재 Setting 환경 변수 값 읽어오기
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingEnvironmentController()),
      ],
      child: MaterialApp(
        title: 'Settings Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SettingsPage(),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final SoundRecorder _soundRecorder = SoundRecorder();
  final List<int> playbackTimeOptions = [1,2, 3, 4, 5,6,7]; // 가능한 재생 시간 목록
  // 사용자가 선택할 수 있는 연설자 목록
  final List<String> speakers = ['Steve Jobs', 'Martin Luther King Jr.', 'Barack Obama', 'Winston Churchill', 'None'];


  @override
  Widget build(BuildContext context) {
    return Consumer<SettingEnvironmentController>(
      builder: (context, controller, child){
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
                      _showRecordingDialog(context,controller);
                    },
                  ),
                  ListTile(
                    title: const Text('음성 템플릿 선택'),
                    subtitle: Text('현재 선택: ${controller.selectedSpeaker}'),
                    onTap: () {
                      _selectSpeakerDialog(context,controller);
                    },
                  ),
                  ListTile(
                    title: const Text('보이스 경고 시간 설정'),
                    subtitle: Text('현재 선택: ${controller.playbackTime} 초'),
                    onTap: () {
                      showPlaybackTimeSettingDialog(context,controller);
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
                    subtitle: Text('현재 선택: ${controller.transcriptDisplayOption}'),
                    onTap: () {
                      _showTranscriptDisplayOptionsDialog(context,controller);
                    },
                  ),
                  ListTile(
                    title: const Text('정렬 방법 고르기'),
                    subtitle: Text('현재 선택: ${controller.selectedSorting}'), // 현재 선택된 정렬 방법 표시
                    onTap:(){
                        _showSortingDialog(context,controller);
                    }
                  ),
          ]
              ),
              ListTile(
                title: const Text('구글 계정 연동'),
                leading: const Icon(Icons.account_circle),
                onTap: () {
                  //구글 드라이브 연동 기능 구현
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _selectSpeakerDialog(BuildContext context, SettingEnvironmentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 선택된 스피커를 찾아서 리스트의 맨 앞으로 이동
        List<String> speakers = ['Steve Jobs', 'Martin Luther King Jr.', 'Barack Obama', 'Winston Churchill', 'None'];
        String currentSelection = controller.selectedSpeaker ?? 'None';  // 현재 선택된 스피커를 가져오거나 기본값 설정
        speakers.remove(currentSelection);  // 현재 선택된 스피커를 리스트에서 제거
        speakers.insert(0, currentSelection);  // 현재 선택된 스피커를 리스트의 맨 앞에 추가

        return AlertDialog(
          title: const Text("음성 템플릿 선택"),
          content: DropdownButton<String>(
            isExpanded: true,
            value: currentSelection,  // 현재 선택된 값을 value로 설정
            items: speakers.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.updateSelectedSpeaker(newValue);
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }


  void _showSortingDialog(BuildContext context, SettingEnvironmentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("정렬 방법 고르기"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('업로드 순'),
                value: '업로드 순',
                groupValue: controller.selectedSorting,
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateSelectedSorting(value);
                  }
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
              RadioListTile<String>(
                title: const Text('최근 수정 일자 순'),
                value: '최근 수정 일자 순',
                groupValue: controller.selectedSorting,
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateSelectedSorting(value);
                  }
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _showRecordingDialog(BuildContext context, SettingEnvironmentController controller) {
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
                              // 경고창을 띄우는 부분
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("권장 사항:"),
                                      content: Text("녹음을 하실 때에는 최대한 일정한 톤으로 마이크 거리를 유지하며 녹음해주세요. 기기가 고정된 상태에 있는 것이 가장 좋습니다."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 경고창 닫기
                                            setState(() {
                                              isRecording = true; // 녹음 시작 상태
                                            });
                                            _soundRecorder.initRecorder();
                                            _soundRecorder.startRecording();
                                          },
                                          child: Text("계속"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 경고창 닫기
                                          },
                                          child: Text("취소"),
                                        ),
                                      ],
                                    );
                                  }
                              );
                            },
                            child: const Text("녹음 시작"),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isRecording = false; // 녹음 중지 상태
                                showPlaybackOptions = true; // 재생 옵션 표시
                                _soundRecorder.stopRecording();
                                controller.updateAverageDB(_soundRecorder.getAverageDb());
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
                            _soundRecorder.playRecordedFile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("녹음된 음성이 재생되었습니다.")),
                            );
                          },
                          child: const Text("녹음 재생"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPlaybackOptions = false;
                              isRecording = true;
                            });
                            _soundRecorder.startRecording();
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
  void showPlaybackTimeSettingDialog(BuildContext context, SettingEnvironmentController controller) {
    final List<int> playbackTimeOptions = [1, 2, 3, 4, 5, 6, 7];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("보이스 경고 시간 설정"),
          content: Container(
            height: 100,
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                controller.updatePlaybackTime(playbackTimeOptions[index]);
              },
              looping: true,
              children: List<Widget>.generate(playbackTimeOptions.length, (int index) {
                return Center(child: Text('${playbackTimeOptions[index]} 초'));
              }),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _showTranscriptDisplayOptionsDialog(BuildContext context, SettingEnvironmentController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("대본 표시 설정"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: const Text('키워드'),
                value: '키워드',
                groupValue: controller.transcriptDisplayOption,
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateTranscriptDisplayOption(value);
                  }
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
              RadioListTile<String>(
                title: const Text('문장 별'),
                value: '문장 별',
                groupValue: controller.transcriptDisplayOption,
                onChanged: (String? value) {
                  if (value != null) {
                    controller.updateTranscriptDisplayOption(value);
                  }
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              ),
            ],
          ),
        );
      },
    );
  }

}

