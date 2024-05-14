// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:hci_project/SettingScreen.dart';
import 'package:hci_project/Script.dart';
import 'package:hci_project/menuListScreen.dart';
import 'package:hci_project/helpScreen.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hci_project/SettingEnvironmentController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingEnvironmentController(),
      child: MaterialApp(
        home: MyHomePage(),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  Future<void> _openFilePickerAndMoveFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? selectedFilePath = result.files.first.path;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String newPath = '$appDocPath/text/${result.files.first.name}';
      Directory newDir = Directory('$appDocPath/text');

      if (!newDir.existsSync()) {
        newDir.createSync(recursive: true);
      }

      try {
        File(selectedFilePath!).copySync(newPath);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('파일을 성공적으로 이동했습니다.')));
        Script tempScript = Script(
            title: result.files.first.name,
            date: DateTime.now(),
            latestdate: DateTime.now());
        Provider.of<SettingEnvironmentController>(context, listen: false)
            .updateScriptList(tempScript);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('파일 이동 중 오류 발생: $e')));
      }
    } else {
      print('파일 선택이 취소되었습니다.');
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpScreen()));
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu, size: 50),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuListScreen()));
              },
            ),
          ],
        ),
      ),
      body: Consumer<SettingEnvironmentController>(
        builder: (context, settings, child) {
          return Container(
            color: Colors.grey[400],
            child: PageView.builder(
              itemCount: settings.getScript.length,
              controller: PageController(viewportFraction: 0.5),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: PageController(viewportFraction: 0.5),
                  builder: (context, child) {
                    double value = 0.8;
                    if (_currentIndex == index) {
                      value = 1.0;
                    } else if (_currentIndex - 1 == index ||
                        _currentIndex + 1 == index) {
                      value = 0.8;
                    } else {
                      value = 0.6;
                    }
                    return Center(
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 100, 0, 100),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        settings.getScript[index].title,
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 110,
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.play_arrow_rounded, color: Colors.black),
                iconSize: 70,
              ),
              IconButton(
                onPressed: () => _openFilePickerAndMoveFile(context),
                icon: Icon(Icons.file_upload_outlined, color: Colors.black),
                iconSize: 70,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                iconSize: 65,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
