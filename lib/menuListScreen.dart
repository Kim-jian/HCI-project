import 'package:flutter/material.dart';
import 'package:hci_project/Script.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:provider/provider.dart';


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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScriptDetailScreen(script: settings.getScript[index]),
                        ),
                      );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Title: ${script.title}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Date: ${script.date}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Latest Date: ${script.latestdate}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
