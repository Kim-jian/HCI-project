import 'package:flutter/material.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:hci_project/SettingScreen.dart';
import 'HomeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingEnvironmentController()),
        ],
        child: const SettingScreen(),// 이곳에 시작할 Screen 입력.(HomeScreen이 되어야함)
    )
  );
}
