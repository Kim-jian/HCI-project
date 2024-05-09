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
      if (currentDb != null) {
        _dbValues.add(currentDb);
      }
    });
  }

  Future<double> stopRecordingAndGetAverageDb() async {
    await _recorder!.stopRecorder();
    double totalDb = _dbValues.fold(0.0, (sum, val) => sum + val);
    double averageDb = totalDb / _dbValues.length;
    _dbValues.clear(); // 값 초기화
    return averageDb;
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
