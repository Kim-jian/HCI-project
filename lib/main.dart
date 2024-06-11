import 'package:flutter/material.dart';
import 'package:hci_project/SettingEnvironmentController.dart';
import 'HomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> requestMicroPermissions() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    print(statuses[Permission.microphone]);  // 권한 요청 결과 로그 출력
  }
  else{
    print("microphone is already granted.");
  }
}


Future<void> requestStoragePermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    print(statuses[Permission.storage]);  // 권한 요청 결과 로그 출력
  }
  else{
    print("storage is already granted.");
  }
}



void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingEnvironmentController()),
        ],
        child: const MyApp(),// 이곳에 시작할 Screen 입력.(HomeScreen이 되어야함)
    )
  );
  requestMicroPermissions(); // 앱 시작 시 권한 요청
  requestStoragePermissions();

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingEnvironmentController>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // 디버그 리본 제거
          theme: ThemeData.light(), // 라이트 모드 테마
          darkTheme: ThemeData.dark(), // 다크 모드 테마
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light, // 테마 모드 설정
          home: HomeScreen(),
        );
      },
    );
  }
}