import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class SoundRecorder {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  List<double> _dbValues = [];

  Future<void> initRecorder() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/my_recording.wav';
    await _recorder!.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
    _recorder!.onProgress!.listen((event) {
      double? currentDb = event.decibels;
      print("Current dB: $currentDb"); // 로그를 추가하여 현재 데시벨 값을 확인
      if (currentDb != null) {
        _dbValues.add(currentDb);
      }
    });
  }

  // 비동기로 녹음을 멈추고, 평균 데시벨 계산을 위한 동기 함수 호출
  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
  }

  // 평균 데시벨 계산을 위한 동기 함수
  double getAverageDb() {
    if (_dbValues.isEmpty) {
      return 0.0;  // 리스트가 비어 있으면 0.0 반환
    }
    double totalDb = _dbValues.fold(0.0, (sum, val) => sum + val);
    double averageDb = totalDb / _dbValues.length;
    _dbValues.clear(); // 리스트 초기화
    print("Passed AverageDB : "+averageDb.toString());
    return averageDb;  // 계산된 평균 데시벨 반환
  }

  Future<void> playRecordedFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/my_recording.wav';
    if (_player!.isPlaying) {
      await _player!.stopPlayer();
    }
    await _player!.startPlayer(fromURI: filePath, codec:Codec.pcm16WAV, whenFinished: () {
      print("Playback finished.");
    });
  }

  void dispose() async {
    if (_recorder!.isRecording) {
      await _recorder!.stopRecorder();
    }
    if (_player!.isPlaying) {
      await _player!.stopPlayer();
    }
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _recorder = null;
    _player = null;
  }
}
