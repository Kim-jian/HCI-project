import 'package:flutter/material.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart'; // Flutter sound for decibel measurement

class SpeechScreen extends StatefulWidget {
  final String scriptContent;

  SpeechScreen({required this.scriptContent});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> with TickerProviderStateMixin {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  List<String> sentences = [];
  List<String> keywordSentences = [];
  int currentSentenceIndex = 0;
  Timer? _timer;
  List<GlobalKey> keys = [];
  bool isPlaying = false;
  bool showKeywordsOnly = false; // 대본 모드를 저장하는 변수
  late double durationPerSentence;
  late double totalDuration; // 전체 대본의 총 시간
  late AnimationController _rabbitController;
  late AnimationController _triangleController;
  double currentDb = 0.0; // 현재 데시벨 값을 저장할 변수
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder(); // Recorder instance for dB measurement

  @override
  void initState() {
    super.initState();
    sentences = widget.scriptContent.split(RegExp(r'(?<=\.)\s+|\n'));
    keys = List.generate(sentences.length, (index) => GlobalKey());
    durationPerSentence = 2.0; // 각 문장의 지속 시간 (초)
    totalDuration = sentences.length * durationPerSentence; // 전체 대본의 총 시간 계산
    _rabbitController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalDuration.toInt()),
    )..addListener(() {
      setState(() {});
    });
    _triangleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalDuration.toInt()),
    )..addListener(() {
      setState(() {});
    });

    // 대문자가 포함된 단어만 추출하여 keywordSentences에 저장, 한 글자 대문자는 제외
    keywordSentences = sentences.map((sentence) {
      return sentence
          .split(' ')
          .where((word) => word.length > 1 && word.contains(RegExp(r'[A-Z]')))
          .join(' ');
    }).toList();

    // Initialize the recorder for decibel measurement
    _initRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _rabbitController.dispose();
    _triangleController.dispose();
    _recorder.closeRecorder(); // Dispose the recorder
    super.dispose();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    _recorder.onProgress!.listen((event) {
      setState(() {
        currentDb = event.decibels ?? 0.0; // Update the current dB value
      });
    });
    await _recorder.startRecorder(toFile: 'dummy.wav');
  }

  void _togglePlayback() {
    if (isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() {
      isPlaying = true;
    });
    _triangleController.forward(); // 빨간 삼각형 재생 시작
  }

  void _pausePlayback() {
    setState(() {
      isPlaying = false;
    });
    _rabbitController.stop();
  }

  void _nextSentence() {
    setState(() {
      if (currentSentenceIndex < sentences.length - 1) {
        currentSentenceIndex++;
        _scrollToCurrentSentence();
        _updatePlaybackTime();
        _rabbitController.value = currentSentenceIndex / (sentences.length - 1);
      }
    });
  }

  void _previousSentence() {
    setState(() {
      if (currentSentenceIndex > 0) {
        currentSentenceIndex--;
        _scrollToCurrentSentence();
        _updatePlaybackTime();
        _rabbitController.value = currentSentenceIndex / (sentences.length - 1);
      }
    });
  }

  void _scrollToCurrentSentence() {
    final context = keys[currentSentenceIndex].currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy;

      final scrollPosition = _scrollController.offset +
          position -
          (MediaQuery.of(context).size.height / 2) +
          (box.size.height / 2);

      _scrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updatePlaybackTime() {
    final settings = Provider.of<SettingEnvironmentController>(context, listen: false);
    final progress = currentSentenceIndex / (sentences.length - 1);
    settings.updatePlaybackTime((progress * 100).toInt());
  }

  void _toggleScriptView() {
    setState(() {
      showKeywordsOnly = !showKeywordsOnly; // 대본 모드 토글
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Top bar with decibel indicators
              _buildTopBar(context),
              // Rabbit and flag progress bar
              _buildProgressBar(context),
              // Main content displaying the script
              Expanded(child: _buildScriptContent(context)),
              // Toolbar buttons
              _buildBottomToolbar(context),
            ],
          ),
          // Transparent button for advancing to the next sentence
          Positioned(
            top: 50, // 깃발 아래
            bottom: 70, // 툴바 위
            right: 0,
            width: MediaQuery.of(context).size.width / 4,
            child: GestureDetector(
              onTap: _nextSentence,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Transparent button for going to the previous sentence
          Positioned(
            top: 50, // 깃발 아래
            bottom: 70, // 툴바 위
            left: 0,
            width: MediaQuery.of(context).size.width / 4,
            child: GestureDetector(
              onTap: _previousSentence,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Consumer<SettingEnvironmentController>(
      builder: (context, settings, child) {
        // 데시벨 값을 조정하는 스케일 팩터
        const scaleFactor = 1; // 적절한 값으로 조정 (0.5는 예시)

        // 스케일을 조정한 currentDb와 averageDB
        double adjustedCurrentDb = currentDb * scaleFactor;
        double adjustedAverageDb = settings.averageDB * scaleFactor;

        // 스케일을 조정한 +20dB와 -20dB 지점
        double adjustedUpperBoundary = (settings.averageDB + 10) * scaleFactor;
        double adjustedLowerBoundary = (settings.averageDB - 10) * scaleFactor;

        // 색상 결정
        Color barColor;
        if (adjustedCurrentDb > adjustedUpperBoundary) {
          barColor = Colors.red;
        } else if (adjustedCurrentDb < adjustedLowerBoundary) {
          barColor = Colors.blue;
        } else {
          barColor = Colors.green;
        }

        return Container(
          height: 50, // 반절 높이로 설정 + 이격
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0), // 상태 표시줄과 이격
            child: Stack(
              children: [
                Positioned(
                  bottom: 0, // 아래쪽 반만 사용
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: 25, // 반절 높이로 설정
                    color: barColor, // 조건부 색상
                    width: (adjustedCurrentDb / 100) * MediaQuery.of(context).size.width, // 조정된 데시벨 값에 따라 너비 조절
                    alignment: Alignment.bottomRight, // 오른쪽 끝에서부터 차오르도록 설정
                  ),
                ),
                // AverageDB 경계선
                Positioned(
                  left: (adjustedAverageDb / 100) * MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                // +20dB 경계선
                Positioned(
                  left: (adjustedUpperBoundary / 100) * MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.red,
                  ),
                ),
                // -20dB 경계선
                Positioned(
                  left: (adjustedLowerBoundary / 100) * MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Consumer<SettingEnvironmentController>(
      builder: (context, settings, child) {
        double endPosition = MediaQuery.of(context).size.width - 24; // End of the progress bar

        return SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: _rabbitController.value * endPosition,
                child: Icon(Icons.directions_run, color: Colors.black, size: 24), // Rabbit icon
              ),
              Positioned(
                left: _triangleController.value * endPosition,
                bottom: 0, // 사람 아이콘 아래에 배치
                child: Icon(Icons.arrow_drop_up, color: Colors.red, size: 24), // Upward arrow icon
              ),
              Positioned(
                left: endPosition,
                child: Icon(Icons.flag, color: Colors.black, size: 24), // Flag icon at the end of the script
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScriptContent(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        _buildFullScriptView(context),
      ],
    );
  }

  Widget _buildFullScriptView(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: sentences.length,
      itemBuilder: (context, index) {
        String text = showKeywordsOnly ? keywordSentences[index] : sentences[index];
        return Container(
          key: keys[index],
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: index == currentSentenceIndex ? Colors.black : Colors.grey,
              fontSize: 18,
              height: 1.5, // 고정된 줄 간격을 설정하여 텍스트 높이를 일정하게 유지
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayback,
          ),
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              _rabbitController.reset();
              _triangleController.reset(); // 빨간 삼각형도 처음으로 이동
              _timer?.cancel();
              setState(() {
                currentSentenceIndex = 0; // Reset to the beginning of the script
                _scrollController.jumpTo(0); // 바로 처음으로 이동
                Provider.of<SettingEnvironmentController>(context, listen: false).updatePlaybackTime(0);
                isPlaying = false;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: _toggleScriptView, // 대본 모드 토글 함수 호출
          ),
        ],
      ),
    );
  }
}