import 'package:flutter/material.dart';
import 'package:hci_project/SettingScreen.dart';
import 'package:hci_project/Script.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  int _currentIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    // 각 아이콘에 해당하는 페이지 위젯들을 여기에 추가합니다.
    // 예를 들어, 아이콘 1에 해당하는 페이지 위젯은 _widgetOptions[0]에 추가합니다.
    Placeholder(), // 재생 페이지로 이동
    Placeholder(), // 업로드 페이지로 이동
    SettingsPage(), // 세팅 페이지로 이동
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.help, size:50),
            onPressed: () { // 도움말 페이지로 이동
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.menu, size: 50),
              onPressed: () { // 메뉴 페이지로 이동
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
          ],
        ),
      ),


      body: Container(
        color: Colors.grey[400],
        child:PageView.builder(
          itemCount: scriptList.length, //scriptList의 길이가 되어야함
          controller: PageController(viewportFraction: 0.5),
          onPageChanged:(index){
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: PageController(viewportFraction: 0.5),
              builder: (context, child){
                double value = 0.8;
                if (_currentIndex == index) {
                  value = 1.0;
                }else if (_currentIndex - 1 == index || _currentIndex + 1 == index){
                  value = 0.6;
                }else{
                  value = 0.4;
                }
                return Center(
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 80, 0, 80),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    scriptList[index].title,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        height: 100,
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                onPressed: () {}, // 재생 페이지로 이동
                icon: Icon(Icons.play_arrow_rounded, color: Colors.black),
                iconSize: 80,
              ),
              IconButton(
                onPressed: () {}, // 업로드 페이지로 이동
                icon: Icon(Icons.file_upload_outlined, color: Colors.black),
                iconSize:80,
              ),
              IconButton(
                onPressed: () { // 설정 페이지로 이동
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                icon: Icon(Icons.settings, color: Colors.black,),
                iconSize:80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

