import 'package:flutter/material.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
  int currentSentenceIndex = 0;
  Timer? _timer;
  List<GlobalKey> keys = [];
  bool isPlaying = false;
  late double durationPerSentence;
  late double totalDuration; // 전체 대본의 총 시간
  late AnimationController _rabbitController;
  late AnimationController _triangleController;

  @override
  void initState() {
    super.initState();
    sentences = widget.scriptContent.split('.'); // Split the content into sentences
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _rabbitController.dispose();
    _triangleController.dispose();
    super.dispose();
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
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: durationPerSentence.toInt()), (timer) {
      setState(() {
        if (currentSentenceIndex < sentences.length - 1) {
          currentSentenceIndex++;
          _scrollToCurrentSentence();
          _updatePlaybackTime();
        } else {
          _stopPlayback();
        }
      });
    });
    _rabbitController.forward();
    _triangleController.forward(); // 빨간 삼각형도 재생 시작
  }

  void _pausePlayback() {
    setState(() {
      isPlaying = false;
    });
    _timer?.cancel();
    _rabbitController.stop();
  }

  void _stopPlayback() {
    setState(() {
      isPlaying = false;
    });
    _timer?.cancel();
    _rabbitController.stop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Consumer<SettingEnvironmentController>(
      builder: (context, settings, child) {
        return Container(
          height: 50,
          color: Colors.grey[300],
          child: Stack(
            children: [
              Container(
                height: 50,
                color: Colors.blueAccent,
                width: (settings.averageDB / 100) * MediaQuery.of(context).size.width, // Scale based on decibels
              ),
              Positioned(
                left: (settings.playbackTime / 100) * MediaQuery.of(context).size.width,
                child: Container(
                  height: 50,
                  width: 2,
                  color: Colors.black,
                ),
              ),
            ],
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
        return Container(
          key: keys[index],
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            sentences[index],
            style: TextStyle(
              color: index == currentSentenceIndex ? Colors.black : Colors.grey,
              fontSize: 18,
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
              _timer?.cancel();
              _rabbitController.reset();
              _triangleController.reset(); // 빨간 삼각형도 리셋
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
            onPressed: () {
              // Toggle between full script and keyword views
              int nextPage = (_pageController.hasClients && _pageController.page != null ? _pageController.page!.round() : 0) == 0 ? 1 : 0;
              _pageController.jumpToPage(nextPage);
            },
          ),
        ],
      ),
    );
  }
}
