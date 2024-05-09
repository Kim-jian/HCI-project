/*
모든 환경 설정 및 앱 현재 환경의 변수를 관리하는 class.
여기서 Getter Setter로 가져와서 앱의 상태를 변경하면 되며,
필요한 환경 변수가 존재 시 이 곳에 선언 후 Getter Setter를 만들기.
*/


//평균 데시벨을 저장하는 것이 필요함.
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

class SettingEnvironmentController extends ChangeNotifier {

  String _selectedSorting = '업로드 순';
  String _selectedSpeaker = 'None';
  int _playbackTime = 1;
  String _transcriptDisplayOption = '키워드';
  Future<double> _averageDB=Future.value(0.0);

  String get selectedSorting => _selectedSorting;
  String get selectedSpeaker => _selectedSpeaker;
  int get playbackTime => _playbackTime;
  String get transcriptDisplayOption => _transcriptDisplayOption;
  Future<double> get averageDB => _averageDB;

  void updateSelectedSorting(String newValue) {
    _selectedSorting = newValue;
    notifyListeners();
  }

  void updateSelectedSpeaker(String newValue) {
    _selectedSpeaker = newValue;
    notifyListeners();
  }

  void updatePlaybackTime(int newTime) {
    _playbackTime = newTime;
    notifyListeners();
  }

  void updateTranscriptDisplayOption(String newOption) {
    _transcriptDisplayOption = newOption;
    notifyListeners();
  }

  void updateAverageDB(Future<double> newDB){
    _averageDB = newDB;
    notifyListeners();
  }
}