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

class _SpeechScreenState extends State<SpeechScreen> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  List<String> sentences = [];
  int currentSentenceIndex = 0;
  Timer? _timer;
  List<GlobalKey> keys = [];

  @override
  void initState() {
    super.initState();
    sentences = widget.scriptContent.split('. '); // Split the content into sentences
    keys = List.generate(sentences.length, (index) => GlobalKey());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPlayback() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        if (currentSentenceIndex < sentences.length - 1) {
          currentSentenceIndex++;
          _scrollToCurrentSentence();
        } else {
          timer.cancel();
        }
      });
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
        double playbackPosition = (settings.playbackTime / 100) * MediaQuery.of(context).size.width;
        double endPosition = MediaQuery.of(context).size.width - 24; // End of the progress bar

        return SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: playbackPosition,
                child: Column(
                  children: [
                    Icon(Icons.directions_run, color: Colors.black, size: 24), // Rabbit icon
                    Icon(Icons.arrow_drop_up, color: Colors.red, size: 24), // Upward arrow icon
                  ],
                ),
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
            icon: Icon(Icons.play_arrow),
            onPressed: _startPlayback,
          ),
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              _timer?.cancel();
              setState(() {
                currentSentenceIndex = 0; // Reset to the beginning of the script
                _scrollToCurrentSentence();
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
