import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'SpeechScreen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  String? _selectedScriptContent;

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
      appBar: AppBar(
        title: Text('대본 목록'),
      ),
      body: Consumer<SettingEnvironmentController>(
        builder: (context, settings, child) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView.builder(
              itemCount: settings.getScript.length,
              itemBuilder: (context, index) {
                Color boxColor = Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!
                    : Colors.white;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      settings.getScript[index].title.replaceAll('.txt', ''), // Remove .txt extension
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall!.color,
                        letterSpacing: 1.2, // 글자 간격을 살짝 넓혀줍니다.
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      String scriptTitle = settings.getScript[index].title;
                      String filePath = 'text/$scriptTitle'; // 파일 경로 예시 (실제로는 알맞게 변경해야 함)
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
