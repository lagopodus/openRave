import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:audio_session/audio_session.dart';

class RaveAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  late Video video;
  Duration position = Duration.zero;
  MediaItem? currentMediaItem;

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

  Future<void> catchUp(String videoId, Duration time, String state) async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    await session.setActive(true);

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should duck.
            print("Audio ducked");
            break;
          case AudioInterruptionType.pause:
            // Another app started playing audio and we should pause.
            print("Audio paused");
            break;
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should pause.
            print("Audio unkown plase");
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption ended and we should unduck.
            print("Audio ducked over");
            break;
          case AudioInterruptionType.pause:
            // The interruption ended and we should resume.
            print("Audio paused over");
            break;
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume.
            print("Audio unkown plase over");
            break;
        }
      }
    });

    _audioPlayer.positionStream.listen((event) {
      position = event;
      notifyListeners();
    });
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenToCurrentPosition();

    await refreshMetadata(videoId);
    var link = await getLink(videoId);
    await _audioPlayer.setUrl(link);
    await _audioPlayer.seek(time); // Seek to the specific time first
    if (state == "playing") {
      _audioPlayer.play(); // Start playing after the seek
    } else {
      _audioPlayer.pause();
    }
  }

  Future<void> loadAndPlay(String videoId) async {
    try {
      await refreshMetadata(videoId);
      var link = await getLink(videoId);
      await _audioPlayer.setUrl(link);
      play();
    } catch (e) {
      print("Error loading video: $e");
    }
  }

  Future<void> refreshMetadata(String videoId) async {
    video = await _yt.videos.get("https://music.youtube.com/watch?v=$videoId");
    currentMediaItem = MediaItem(
      id: videoId,
      album: "YouTube Music",
      title: video.title,
      artist: video.author,
      duration: video.duration,
      artUri: Uri.parse(
          "https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=$videoId"),
    );
    mediaItem.add(currentMediaItem!);
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
    _audioPlayer.dispose();
    _yt.close();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> skipToPrevious() async {
    //always restart the song instead of going back one song. I dont want that now!
    await _audioPlayer.seek(Duration.zero);
  }

  @override
  Future<void> skipToNext() async {
    _audioPlayer.seek(_audioPlayer.duration!);
    _audioPlayer.pause();
  }

  bool get isPlaying => _audioPlayer.playing;

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _audioPlayer.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _audioPlayer.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.skipToPrevious,
          MediaAction.seek,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_audioPlayer.processingState]!,
        playing: playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenToCurrentPosition() {
    _audioPlayer.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });
  }
}
