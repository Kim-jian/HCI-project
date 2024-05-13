import 'package:hci_project/SettingEnvironmentController.dart';
import 'package:hci_project/Script.dart';


class ScriptManager{
  SettingEnvironmentController _settingEnvironmentController = SettingEnvironmentController();
  List<Script> scriptList = [
    Script(
      title: '찌안이꼬츄',
      content: 'This is the content of script 1.',
      date: '2023.05.10',
      latestdate: '2023.05.19',
    ),
    Script(
      title: '뱁배개벅벅',
      content: 'This is the content of script 2.',
      date: '2023.05.11',
      latestdate: '2023.05.18',
    ),
    Script(
      title: '아냐포져',
      content: 'This is the content of script 3.',
      date: '2023.05.15',
      latestdate: '2023.05.17',
    ),
    Script(
      title: '계란말이요요',
      content: 'This is the content of script 4.',
      date: '2023.05.14',
      latestdate: '2023.05.16',
    ),
    Script(
      title: '뱁배개먹고싶오요',
      content: 'This is the content of script 5.',
      date: '2023.05.13',
      latestdate: '2023.05.15',
    ),
    // Add more scripts as needed
  ];

  List<Script> get getScript => scriptList;
  Function get sortScriptList => _sortScriptList;

  void _sortScriptList() {
    String sortingType = _settingEnvironmentController.selectedSorting;

    if (sortingType == '업로드 순') {
      // 업로드 순으로 정렬
      scriptList.sort((a, b) => b.date.compareTo(a.date));


    } else if (sortingType == '최근 열람 일자 순') {
      // 수정 순으로 정렬
      scriptList.sort((a, b) => b.date.compareTo(a.date));
    }
  }
}

//업로드 구현


