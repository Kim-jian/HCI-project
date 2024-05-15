import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hci_project/SettingEnvironmentController.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  // PageController for navigating between different views
  PageController _pageController = PageController();

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
        double averageDbPosition = (settings.averageDB / 100) * MediaQuery.of(context).size.width;
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
              if (settings.getScript.isNotEmpty)
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
    return Consumer<SettingEnvironmentController>(
      builder: (context, settings, child) {
        if (settings.getScript.isEmpty) {
          return Center(
            child: Text("No scripts available"),
          );
        }
        return PageView(
          controller: _pageController,
          children: [
            // Full script view
            _buildFullScriptView(context, settings),
            // Keyword view
            _buildKeywordView(context, settings),
          ],
        );
      },
    );
  }

  Widget _buildFullScriptView(BuildContext context, SettingEnvironmentController settings) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: settings.getScript.map((script) {
          return Text(
            script.title,
            style: TextStyle(
              color: settings.getScript.indexOf(script) == (_pageController.page?.round() ?? 0) ? Colors.black : Colors.grey,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeywordView(BuildContext context, SettingEnvironmentController settings) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: settings.getScript.map((script) {
          return Text(
            script.title.split(' ').first, // Assuming the first word as a keyword for simplicity
            style: TextStyle(
              color: settings.getScript.indexOf(script) == (_pageController.page?.round() ?? 0) ? Colors.black : Colors.grey,
            ),
          );
        }).toList(),
      ),
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
            onPressed: () {
              // Start playing the script
            },
          ),
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              _pageController.jumpToPage(0); // Reset to the beginning of the script
            },
          ),
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              // Toggle between full script and keyword views
              int nextPage = (_pageController.page?.round() ?? 0) == 0 ? 1 : 0;
              _pageController.jumpToPage(nextPage);
            },
          ),
        ],
      ),
    );
  }
}
