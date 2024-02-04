import 'package:audioplayers/audioplayers.dart';

class Music {
  void play(String which) {
    AudioPlayer player = AudioPlayer();
    player.play(AssetSource("msc/$which.wav"));
    // 不能有前缀 assets/ 很奇怪
  }
}
