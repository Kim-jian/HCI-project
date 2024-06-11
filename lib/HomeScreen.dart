import 'package:flutter/material.dart';
import 'package:hci_project/SettingScreen.dart';
import 'package:hci_project/Script.dart';
import 'package:hci_project/menuListScreen.dart';
import 'package:hci_project/helpScreen.dart';
import 'package:hci_project/SpeechScreen.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hci_project/SettingEnvironmentController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingEnvironmentController(),
      child: Consumer<SettingEnvironmentController>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // 디버그 리본 제거
            theme: ThemeData.light(), // 라이트 모드 테마
            darkTheme: ThemeData.dark(), // 다크 모드 테마
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light, // 테마 모드 설정
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  String? _selectedScriptContent;
  var _settingsT;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _openFilePickerAndMoveFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null) {
      String? selectedFilePath = result.files.single.path;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String newPath = '$appDocPath/text/${result.files.single.name}';
      Directory newDir = Directory('$appDocPath/text');

      if (!newDir.existsSync()) {
        newDir.createSync(recursive: true);
      }

      try {
        File(selectedFilePath!).copySync(newPath);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일을 성공적으로 이동했습니다.')));

        Script tempScript = Script(
            title: result.files.single.name,
            date: DateTime.now(),
            latestdate: DateTime.now());

        Provider.of<SettingEnvironmentController>(context, listen: false).updateScriptList(tempScript);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일 이동 중 오류 발생: $e')));
      }
    } else {
      print('파일 선택이 취소되었습니다.');
    }
  }

  Future<void> _deleteFileAndRemoveFromList(BuildContext context, Script script) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/text/${script.title}';
      print(filePath);
      File fileToDelete = File(filePath);


      if (fileToDelete.existsSync()) {
        fileToDelete.deleteSync();
        Provider.of<SettingEnvironmentController>(context, listen: false).removeScriptFromList(script);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일을 성공적으로 삭제했습니다.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일을 찾을 수 없습니다.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('파일 삭제 중 오류 발생: $e')));
      }
    }
  }



  Future<void> _confirmAndDeleteFile(BuildContext context1, Script script) async {
    showDialog(
      context: context1,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('파일 삭제'),
          content: Text('정말 이 파일을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteFileAndRemoveFromList(context1, script);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }



  Future<String> _extractTextFromTxt(String filePath) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String newPath = '$appDocPath/$filePath';

      File file = File(newPath);
      String scriptContent = await file.readAsString();
      return scriptContent;
    } catch (e) {
      print('파일에서 텍스트를 추출하는 중 오류 발생: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.help, size: 50),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen()));
            },
          ),
          actions: <Widget>[
            Consumer<SettingEnvironmentController>(
              builder: (context, settings, child) {
                return IconButton(
                  icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 50),
                  onPressed: () {
                    settings.updateDarkMode();
                  },
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.menu, size: 50),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MenuListScreen()));
              },
            ),
          ],
        ),
      ),
      body: Consumer<SettingEnvironmentController>(
        builder: (context, settings, child) {
          _settingsT = settings;
          return Container(
            color: settings.isDarkMode ? Colors.grey[850] : Colors.grey[400],
            child: PageView.builder(
              itemCount: settings.getScript.length,
              controller: PageController(viewportFraction: 0.7),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: PageController(viewportFraction: 0.7),
                  builder: (context, child) {
                    double value = 0.8;
                    if (_currentIndex == index) {
                      value = 1.0;
                    } else if (_currentIndex - 1 == index || _currentIndex + 1 == index) {
                      value = 0.9;
                    } else {
                      value = 0.8;
                    }
                    return Center(
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () async {
                      String scriptTitle = settings.getScript[index].title;
                      String filePath = 'text/$scriptTitle'; // 파일 경로
                      try {
                        String scriptContent = await _extractTextFromTxt(filePath);
                        _selectedScriptContent = scriptContent;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpeechScreen(scriptContent: _selectedScriptContent!),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('파일을 로드하는 도중 오류 발생: $e')),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10, 80, 10, 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: settings.isDarkMode ? Colors.black : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                settings.getScript[index].title.replaceAll('.txt', ''), // Remove .txt extension
                                style: TextStyle(
                                  color: settings.isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmAndDeleteFile(context, settings.getScript[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<SettingEnvironmentController>(
        builder: (context, settings, child) {
          return BottomAppBar(
            height: 90,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            String scriptTitle = _settingsT.getScript[_currentIndex].title;
                            String filePath = 'text/$scriptTitle'; // 파일 경로
                            try {
                              String scriptContent = await _extractTextFromTxt(filePath);
                              _selectedScriptContent = scriptContent;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpeechScreen(scriptContent: _selectedScriptContent!),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('파일을 로드하는 도중 오류 발생: $e')),
                              );
                            }
                          },
                          icon: Icon(Icons.play_arrow_rounded, color: Theme.of(context).iconTheme.color),
                          iconSize: 50,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _openFilePickerAndMoveFile(context),
                          icon: Icon(Icons.file_upload_outlined, color: Theme.of(context).iconTheme.color),
                          iconSize: 50,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                          },
                          icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
                          iconSize: 50,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
