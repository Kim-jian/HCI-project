import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hci_project/Script.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'SpeechScreen.dart';


class MenuListScreen extends StatelessWidget {
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
        backgroundColor: Colors.grey[400],
      ),
      body: Container(
        color: Colors.grey[400],
        child: Consumer<SettingEnvironmentController>(
          builder: (context, settings, child) {
            return ListView.builder(
              itemCount: settings.getScript.length,
              itemBuilder: (context, index) {
                Color backgroundColor = Colors.white;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: Text(
                      settings.getScript[index].title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            );
          },
        ),
      ),
    );
  }
}