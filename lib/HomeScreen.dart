import 'package:flutter/material.dart';
import 'package:hci_project/SettingScreen.dart';


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
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.help),
          onPressed: () {
            // 도움말 아이콘을 눌렀을 때 수행할 작업을 여기에 추가하세요.
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // 메뉴바 아이콘을 눌렀을 때 수행할 작업을 여기에 추가하세요.
            },
          ),
        ],
      ),

      body: PageView.builder(
        itemCount: 3, //scriptList의 길이가 되어야함
        controller: PageController(viewportFraction: 0.5),
        onPageChanged:(index){
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: PageController(viewportFraction: 0.8),
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
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Page ${index + 1}',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        // child: Container(
        //   height:70,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: <Widget>[
        //       IconButton(
        //           onPressed: () {},
        //           icon: Icon(Icons.play_arrow_rounded)
        //       ),
        //       IconButton(
        //           onPressed: () {},
        //           icon: Icon(Icons.file_upload_outlined)),
        //       IconButton(
        //           onPressed: () {},
        //           icon: Icon(Icons.settings)),
        //     ],
        //   ),
        // ),
        iconSize: 100.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow_rounded,
            color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload_outlined,
            color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
            color: Colors.black),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

