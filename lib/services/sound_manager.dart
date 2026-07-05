import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static bool _muted = false;
  static final AudioPlayer _player = AudioPlayer();

  static void toggleMute() => _muted = !_muted;
  static bool isMuted() => _muted;
  static void playTap() {}

  static Future<void> _play(String asset) async {
    if (_muted) return;
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  static void playMove() => _play('sounds/move.mp3');
  static void playTiger() => _play('sounds/tiger.mp3');
  static void playGoat() => _play('sounds/goat.mp3');
  static void playCelebration() => _play('sounds/celebration.mp3');

  static void playTigerWin() {
    playTiger();
    Future.delayed(const Duration(milliseconds: 450), playCelebration);
  }

  static void playGoatWin() {
    playGoat();
    Future.delayed(const Duration(milliseconds: 450), playCelebration);
  }
}
