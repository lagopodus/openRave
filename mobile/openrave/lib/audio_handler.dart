import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RaveAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  final String _artistName = "";
  final String _songTitle = "";
  final String _coverUrl =
      "https://placehold.co/400/transparent/transparent/png";
  final int _duration = 0;
  final int _progress = 0;
  final bool _isPlaying = false;
  final String _videoId = "";

  // Getters
  String get artistName => _artistName;
  String get songTitle => _songTitle;
  String get coverUrl => _coverUrl;
  int get duration => _duration;
  int get progress => _progress;
  bool get isPlaying => _isPlaying;
  String get videoId => _videoId;

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
      var link = await getLink(videoId);
      await _audioPlayer.setUrl(link);
      await play();
      refreshMetadata();
    } catch (e) {
      print(e);
    }
  }

  void refreshMetadata() {
    var video = _yt.videos.get("https://music.youtube.com/watch?v=$_videoId");
    artistName = video.author;
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
