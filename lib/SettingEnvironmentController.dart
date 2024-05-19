import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hci_project/Script.dart';

class SettingEnvironmentController extends ChangeNotifier {

  String _selectedSorting = '업로드 순';
  String _selectedSpeaker = 'None';
  int _playbackTime = 1;
  String _transcriptDisplayOption = '키워드';
  double _averageDB = 0.0;
  List<Script> _scriptList = [];

  SettingEnvironmentController() {
    loadInitialSettings();
  }

  List<Script> get getScript => _scriptList;
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
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      print("Invalid type");
    }
  }

  void updateDBtemp(String speaker) {
    switch (speaker) {
      case 'Steve Jobs':
        _averageDB = 70.0;
        break;
      case 'Martin Luther King Jr.':
        _averageDB = 85.0;
        break;
      case 'Barack Obama':
        _averageDB = 75.0;
        break;
      case 'Winston Churchill':
        _averageDB = 80.0;
        break;
      case 'None':
        _averageDB = 0.0;
        break;
    }
    saveSettings("averageDB", _averageDB);
    notifyListeners();
  }

  void updateSelectedSorting(String newValue) {
    _selectedSorting = newValue;
    saveSettings("selectedSorting", newValue);
    sortScriptList();
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

  void updateScriptList(Script newScript) {
    _scriptList.add(newScript);
    saveScriptList();
    notifyListeners();
  }

  void removeScriptFromList(Script script) {
    _scriptList.remove(script);
    saveScriptList();
    notifyListeners();
  }

  void updateTranscriptDisplayOption(String newOption) {
    _transcriptDisplayOption = newOption;
    saveSettings("transcriptDisplayOption", newOption);
    notifyListeners();
  }

  void updateAverageDB(double newDB) {
    _averageDB = newDB;
    saveSettings("averageDB", newDB);
    notifyListeners();
  }

  Future<void> saveScriptList() async {
    List<String> scriptListJson = _scriptList.map((script) => json.encode(script.toJson())).toList();
    await saveSettings("scriptList", scriptListJson);
  }

  Future<void> loadInitialSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedSorting = prefs.getString('selectedSorting') ?? _selectedSorting;
    print("Loaded Sorting: $_selectedSorting");
    _selectedSpeaker = prefs.getString('selectedSpeaker') ?? _selectedSpeaker;
    _playbackTime = prefs.getInt('playbackTime') ?? _playbackTime;
    _transcriptDisplayOption = prefs.getString('transcriptDisplayOption') ?? _transcriptDisplayOption;
    _averageDB = prefs.getDouble('averageDB') ?? _averageDB;
    print("Loaded Average DB: $_averageDB");

    List<String>? scriptListJson = prefs.getStringList('scriptList');
    if (scriptListJson != null) {
      _scriptList = scriptListJson.map((script) => Script.fromJson(json.decode(script))).toList();
    }

    notifyListeners();
  }

  void sortScriptList() {
    if (_selectedSorting == '업로드 순') {
      // 업로드 순으로 정렬
      _scriptList.sort((a, b) => a.date.compareTo(b.date));
    } else if (_selectedSorting == '최근 열람 순') {
      // 수정 순으로 정렬
      _scriptList.sort((a, b) => b.latestdate.compareTo(a.latestdate));
    }
  }
}
