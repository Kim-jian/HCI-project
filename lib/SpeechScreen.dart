import 'package:flutter/material.dart';
import 'SettingEnvironmentController.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart'; // Flutter sound for decibel measurement

class SpeechScreen extends StatefulWidget {
  final String scriptContent;

  SpeechScreen({required this.scriptContent});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  List<String> sentences = [];
  List<String> keywordSentences = [];
  List<double> sentenceDurations = [];
  int currentSentenceIndex = 0;
  Timer? _timer;
  List<GlobalKey> keys = [];
  bool isPlaying = false;
  bool showKeywordsOnly = false; // 대본 모드를 저장하는 변수
  late double totalDuration; // 전체 대본의 총 시간
  late AnimationController _rabbitController;
  late AnimationController _triangleController;
  double currentDb = 0.0; // 현재 데시벨 값을 저장할 변수
  final FlutterSoundRecorder _recorder =
  FlutterSoundRecorder(); // Recorder instance for dB measurement
  Timer? _dbCheckTimer; // 데시벨 체크 타이머
  int lowDbDuration = 0; // 낮은 데시벨 유지 시간
  bool showWarningMessage = false; // 경고 메시지 표시 여부
  bool showWarningLine = false; // 경고선 표시 여부
  int wordsPerMinute=120;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingEnvironmentController>(context);
    updateWordsPerMinute(settings.selectedSpeaker); // Update WPM based on the selected speaker
    updateDurations(); // Recalculate durations based on the new WPM
  }

  void updateWordsPerMinute(String selectedSpeaker) {
    switch (selectedSpeaker) {
      case "Steve Jobs":
        wordsPerMinute = 125;
        break;
      case "Martin Luther King Jr.":
        wordsPerMinute = 110;
        break;
      case "Barack Obama":
        wordsPerMinute = 130;
        break;
      case "Winston Churchill":
        wordsPerMinute = 100;
        break;
      default:
        wordsPerMinute = 120;
        break;
    }
  }

  void updateDurations() {
    sentenceDurations = sentences.map((sentence) => _calculateSentenceDuration(sentence)).toList();
    totalDuration = sentenceDurations.reduce((a, b) => a + b);
  }

  @override
  void initState() {
    super.initState();
    switch(SettingEnvironmentController().selectedSpeaker){
      case "Steven Jobs":
        wordsPerMinute = 125;
        break;
      case "Martin Luther King Jr." :
        wordsPerMinute = 110;
        break;
      case "Barack Obama":
        wordsPerMinute = 130;
        break;
      case "Winston Churchill":
        wordsPerMinute = 100;
        break;
      default:
        wordsPerMinute = 120;
        break;
    }
    sentences = widget.scriptContent.split(RegExp(r'(?<=\.)\s+|\n'));
    keys = List.generate(sentences.length, (index) => GlobalKey());
    sentenceDurations = sentences
        .map((sentence) => _calculateSentenceDuration(sentence))
        .toList();
    totalDuration = sentenceDurations.reduce((a, b) => a + b); // 전체 대본의 총 시간 계산
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

    // Initialize the recorder for decibel measurement
    _initRecorder();

    // Set initial transcript display mode based on the SettingEnvironmentController's value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings =
      Provider.of<SettingEnvironmentController>(context, listen: false);
      setState(() {
        showKeywordsOnly = settings.transcriptDisplayOption == '키워드';
        if (showKeywordsOnly) {
          _generateKeywordSentences(settings.keywordSentence);
        }
      });
    });
  }

  void _generateKeywordSentences(int interval) {
    keywordSentences = List.generate(sentences.length, (index) {
      if (index % interval == 0) {
        List<String> words = sentences[index].split(' ');
        return words.length > 1 ? '${words[0]} ${words[1]}' : words[0];
      }
      return '';
    });
  }

  double _calculateSentenceDuration(String sentence) {
    int wordCount = sentence.split(' ').length;
    return (wordCount/wordsPerMinute) * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _rabbitController.dispose();
    _triangleController.dispose();
    _recorder.closeRecorder(); // Dispose the recorder
    _dbCheckTimer?.cancel(); // 데시벨 체크 타이머 해제
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

    // 데시벨 체크 타이머 시작
    _startDbCheckTimer();
  }

  void _startDbCheckTimer() {
    _dbCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final settings =
      Provider.of<SettingEnvironmentController>(context, listen: false);
      final adjustedLowerBoundary = settings.averageDB - 20;
      final warningBoundary = adjustedLowerBoundary - 20;
      final warningDuration = settings.playbackTime;

      if (currentDb < warningBoundary) {
        lowDbDuration++;
        if (lowDbDuration >= warningDuration) {
          _showWarning();
          lowDbDuration = 0; // 경고 후 다시 초기화
        }
      } else {
        lowDbDuration = 0; // 데시벨이 다시 높아지면 초기화
        setState(() {
          showWarningLine = false; // 경고선 숨기기
        });
      }
    });
  }

  void _showWarning() {
    setState(() {
      showWarningMessage = true; // 경고 메시지 표시
      showWarningLine = true; // 경고선 표시
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showWarningMessage = false; // 경고 메시지 숨기기
        showWarningLine = false; // 경고선 숨기기
      });
    });
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
    _triangleController.stop(); // 빨간 삼각형 일시정지
  }

  void _nextSentence() {
    setState(() {
      final settings =
      Provider.of<SettingEnvironmentController>(context, listen: false);
      if (showKeywordsOnly) {
        if (currentSentenceIndex <
            sentences.length - settings.keywordSentence) {
          currentSentenceIndex += settings.keywordSentence;
        } else {
          currentSentenceIndex = sentences.length - 1;
        }
      } else {
        if (currentSentenceIndex < sentences.length - 1) {
          currentSentenceIndex++;
        }
      }
      _scrollToCurrentSentence();
      _updatePlaybackTime();
      _rabbitController.value = currentSentenceIndex / (sentences.length - 1);
    });
  }

  void _previousSentence() {
    setState(() {
      final settings =
      Provider.of<SettingEnvironmentController>(context, listen: false);
      if (showKeywordsOnly) {
        if (currentSentenceIndex > settings.keywordSentence - 1) {
          currentSentenceIndex -= settings.keywordSentence;
        } else {
          currentSentenceIndex = 0;
        }
      } else {
        if (currentSentenceIndex > 0) {
          currentSentenceIndex--;
        }
      }
      _scrollToCurrentSentence();
      _updatePlaybackTime();
      _rabbitController.value = currentSentenceIndex / (sentences.length - 1);
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
    final settings =
    Provider.of<SettingEnvironmentController>(context, listen: false);
    final progress = currentSentenceIndex / (sentences.length - 1);
    settings.updatePlaybackTime((progress * 100).toInt());
  }

  void _toggleScriptView() {
    setState(() {
      showKeywordsOnly = !showKeywordsOnly; // 대본 모드 토글
      if (showKeywordsOnly) {
        final settings =
        Provider.of<SettingEnvironmentController>(context, listen: false);
        _generateKeywordSentences(settings.keywordSentence);
      }
    });
  }

  String _formatDuration(double seconds) {
    Duration duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
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
            top: 50,
            // 깃발 아래
            bottom: 70,
            // 툴바 위
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
            top: 50,
            // 깃발 아래
            bottom: 70,
            // 툴바 위
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
          // 경고 메시지 표시
          if (showWarningMessage)
            Positioned(
              bottom: 100,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Container(
                width: 200,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: Colors.red,
                child: Text(
                  '설정해둔 시간보다 긴 시간동안 발표가 멈췄습니다. 발표를 시작하세요.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
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
        const scaleFactor = 1; // 적절한 값으로 조정

        // 스케일을 조정한 currentDb와 averageDB
        double adjustedCurrentDb = currentDb * scaleFactor;
        double adjustedAverageDb = settings.averageDB * scaleFactor;

        // 스케일을 조정한 +20dB와 -20dB 지점
        double adjustedUpperBoundary = (settings.averageDB + 10) * scaleFactor;
        double adjustedLowerBoundary = (settings.averageDB - 10) * scaleFactor;
        double warningBoundary = adjustedLowerBoundary - 20 * scaleFactor;

        // 색상 결정
        Color barColor;
        if (adjustedCurrentDb > adjustedUpperBoundary) {
          barColor = Colors.red;
        } else if (adjustedCurrentDb < adjustedLowerBoundary) {
          barColor = Colors.red;
        } else {
          barColor = Colors.green;
        }
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 50, // 반절 높이로 설정 + 이격
          color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0), // 상태 표시줄과 이격
            child: Stack(
              children: [
                Positioned(
                  bottom: 0, // 아래쪽 반만 사용
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: 25,
                    // 반절 높이로 설정
                    color: barColor,
                    // 조건부 색상
                    width: (adjustedCurrentDb / 100) *
                        MediaQuery.of(context).size.width,
                    // 조정된 데시벨 값에 따라 너비 조절
                    alignment: Alignment.bottomRight, // 오른쪽 끝에서부터 차오르도록 설정
                  ),
                ),
                // AverageDB 경계선
                Positioned(
                  left: (adjustedAverageDb / 100) *
                      MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                // +20dB 경계선
                Positioned(
                  left: (adjustedUpperBoundary / 100) *
                      MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.red,
                  ),
                ),
                // -20dB 경계선
                Positioned(
                  left: (adjustedLowerBoundary / 100) *
                      MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Container(
                    height: 25,
                    width: 2,
                    color: Colors.blue,
                  ),
                ),
                // 경고선
                if (showWarningLine)
                  Positioned(
                    left: (warningBoundary / 100) *
                        MediaQuery.of(context).size.width,
                    bottom: 0,
                    child: Container(
                      height: 25,
                      width: 2,
                      color: Colors.red,
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
        double endPosition =
            MediaQuery.of(context).size.width - 34; // End of the progress bar

        return SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: _rabbitController.value * endPosition,
                child: Icon(Icons.directions_run,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, size: 24), // Rabbit icon
              ),
              Positioned(
                left: 0, // 사람 아이콘의 오른쪽 끝
                top: 24, // 수평선의 y 위치 조정
                child: Container(
                  height: 2,
                  width: 500,
                  color: Colors.grey,
                ),
              ),
              Positioned(
                left: _triangleController.value * endPosition,
                top: 20, // 사람 아이콘 아래에 배치
                child: Icon(Icons.arrow_drop_up, color: Colors.red, size: 24), //Upward arrow icon
              ),
              Positioned(
                left: endPosition,
                child: Column(
                  children: [
                    Icon(Icons.flag,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, size: 24), // Flag icon
                    Text(
                      _formatDuration(totalDuration),
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 12),
                    ),
                  ],
                ) // Flag icon at the end of the script
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
        // 키워드 모드에서 빈칸을 표시하지 않도록 처리
        if (showKeywordsOnly && keywordSentences[index].isEmpty) {
          return Container(); // 빈 컨테이너를 반환하여 렌더링하지 않음
        }
        String text =
        showKeywordsOnly ? keywordSentences[index] : sentences[index];
        if(Theme.of(context).brightness == Brightness.dark){
          return Container(
            key: keys[index],
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: index == currentSentenceIndex ? Colors.white : Colors.grey,
                fontSize: 18,
                height: 1.5, // 고정된 줄 간격을 설정하여 텍스트 높이를 일정하게 유지
              ),
            ),
          );
        }else{
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
        }
      },
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 70,
      color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Theme.of(context).iconTheme.color),
            onPressed: _togglePlayback,
          ),
          IconButton(
            icon: Icon(Icons.replay, color: Theme.of(context).iconTheme.color),
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
            icon: Icon(Icons.swap_horiz, color: Theme.of(context).iconTheme.color),
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
              _toggleScriptView(); // 대본 모드 토글 함수 호출
            },
          ),
        ],
      ),
    );
  }

}
