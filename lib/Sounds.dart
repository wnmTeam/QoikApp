import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Sounds {
  AudioPlayer audioPlayer = AudioPlayer();

  Future<AudioPlayer> sendMessageSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("hat.wav");
  }

  Future<AudioPlayer> commentSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("hat.wav");
  }

  Future<AudioPlayer> likeSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("hat.wav");
  }

  Future<AudioPlayer> disLikeSound() async {
    // AudioCache cache = new AudioCache();
    // return await cache.play("hat.wav");
  }

  Future<AudioPlayer> postSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("hat.wav");
  }

  dispose() {
    audioPlayer.dispose();
  }
}
