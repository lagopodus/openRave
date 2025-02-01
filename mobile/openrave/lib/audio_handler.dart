import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaveAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  late Video video;
  Duration position = Duration.zero;

  Future<String> getLink(String id) async {
    var manifest = await _yt.videos.streamsClient.getManifest(id, ytClients: [
      YoutubeApiClient.androidVr,
      YoutubeApiClient.android,
      YoutubeApiClient.ios,
      YoutubeApiClient.safari
    ]);
    return Platform.isIOS
        ? manifest.muxed.withHighestBitrate().url.toString()
        : manifest.audioOnly.withHighestBitrate().url.toString();
  }

  Future<void> loadAndPlay(String videoId) async {
    try {
      refreshMetadata(videoId);
      var link = await getLink(videoId);
      await _audioPlayer.setUrl(link);
      play();
    } catch (e) {
      print(e);
    }
  }

  void refreshMetadata(String videoId) async {
    video = await _yt.videos.get("https://music.youtube.com/watch?v=$videoId");
    _audioPlayer.positionStream.listen((event) {
      position = event;
      notifyListeners();
    });
    notifyListeners();
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

  bool get isPlaying {
    if (_audioPlayer.playerState.playing) {
      return true;
    } else {
      return false;
    }
  }
}
