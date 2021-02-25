import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Sounds {
  AudioPlayer audioPlayer = AudioPlayer();

  Future<AudioPlayer> sendMessageSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("message_out.wav");
  }

  Future<AudioPlayer> inMessageSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("message_in.wav");
  }

  Future<AudioPlayer> likeSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("like.ogg");
  }

  Future<AudioPlayer> disLikeSound() async {
    // AudioCache cache = new AudioCache();
    // return await cache.play("disLike.wav");
  }

  Future<AudioPlayer> commentSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("comment.ogg");
  }

  Future<AudioPlayer> postSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("post.wav");
  }

  Future<AudioPlayer> notificationSound() async {
    AudioCache cache = new AudioCache();
    return await cache.play("notification.ogg");
  }

  dispose() {
    audioPlayer.dispose();
  }
}
