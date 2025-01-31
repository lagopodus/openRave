import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaveAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  Future<void> loadAndPlay(String videoId) async {
    try {
      print("1");
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);
      print("2");
      var audioStream = Platform.isIOS
          ? manifest.muxed.withHighestBitrate()
          : manifest.audioOnly.withHighestBitrate();
      print("3");
      String audioUrl = audioStream.url.toString();
      print("4 $audioUrl");
      await _audioPlayer.setUrl(audioUrl);
      print("5");
      _audioPlayer.play();
    } catch (e) {
      print("Error loading YouTube audio: $e");
    }
  }

  @override
  Future<void> play() => _audioPlayer.play();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _yt.close();
  }
}
