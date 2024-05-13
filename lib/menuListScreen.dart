import 'package:flutter/material.dart';
import 'package:hci_project/Script.dart';
import 'package:hci_project/ScriptManager.dart';

ScriptManager _scriptManager = ScriptManager();
List<Script> scriptList = _scriptManager.getScript;

class MenuListScreen extends StatelessWidget {
  const MenuListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대본 목록'),
        backgroundColor: Colors.grey[400],
      ),
      body: Container(
        color: Colors.grey[400],
        child: ListView.builder(
          itemCount: scriptList.length,
          itemBuilder: (context, index) {
            Color backgroundColor = Colors.white;
            return Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color:backgroundColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: ListTile(
                title: Text(
                  scriptList[index].title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ), // 각 스크립트의 제목을 표시합니다.
                onTap: () {
                  // 사용자가 항목을 탭했을 때 실행할 동작을 여기에 추가하세요.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScriptDetailScreen(script: scriptList[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class ScriptDetailScreen extends StatelessWidget {
  final Script script;

  ScriptDetailScreen({required this.script});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(script.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(script.content), // 스크립트의 내용을 표시합니다.
      ),
    );
  }
}
