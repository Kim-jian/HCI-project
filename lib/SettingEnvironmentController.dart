/*
모든 환경 설정 및 앱 현재 환경의 변수를 관리하는 class.
여기서 Getter Setter로 가져와서 앱의 상태를 변경하면 되며,
필요한 환경 변수가 존재 시 이 곳에 선언 후 Getter Setter를 만들기.
*/


//평균 데시벨을 저장하는 것이 필요함.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingEnvironmentController extends ChangeNotifier {

  String _selectedSorting = '업로드 순';
  String _selectedSpeaker = 'None';
  int _playbackTime = 1;
  String _transcriptDisplayOption = '키워드';
  double _averageDB=0.0;

  SettingEnvironmentController(){
    loadInitialSettings();
  }

  String get selectedSorting => _selectedSorting;
  String get selectedSpeaker => _selectedSpeaker;
  int get playbackTime => _playbackTime;
  String get transcriptDisplayOption => _transcriptDisplayOption;
  double get averageDB => _averageDB;

  Future<void> saveSettings(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      print("Invalid type");
    }
  }



  void updateSelectedSorting(String newValue) {
    _selectedSorting = newValue;
    saveSettings("selectedSorting", newValue);
    notifyListeners();
  }

  void updateSelectedSpeaker(String newValue) {
    _selectedSpeaker = newValue;
    saveSettings("selectedSpeaker", newValue);
    notifyListeners();
  }

  void updatePlaybackTime(int newTime) {
    _playbackTime = newTime;
    saveSettings("playbackTime", newTime);
    notifyListeners();
  }

  void updateTranscriptDisplayOption(String newOption) {
    _transcriptDisplayOption = newOption;
    saveSettings("transcriptDisplayOption", newOption);
    notifyListeners();
  }

  void updateAverageDB(double newDB){
    _averageDB = newDB;
    saveSettings("averageDB", newDB);
    notifyListeners();
  }

  Future<void> loadInitialSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedSorting = prefs.getString('selectedSorting') ?? _selectedSorting;
    print("Loaded Sorting: $_selectedSorting");
    _selectedSpeaker = prefs.getString('selectedSpeaker') ?? _selectedSpeaker;
    _playbackTime = prefs.getInt('playbackTime') ?? _playbackTime;
    _transcriptDisplayOption = prefs.getString('transcriptDisplayOption') ?? _transcriptDisplayOption;
    double averageDBValue = prefs.getDouble('averageDB') ?? 0.0;
    _averageDB = averageDBValue;
    print("Loaded Average DB: $averageDBValue");
    notifyListeners();
  }

  
}