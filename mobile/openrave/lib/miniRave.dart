import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio_handler.dart';

class MiniRave extends StatefulWidget {
  const MiniRave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<MiniRave> createState() => _MiniRaveState();
}

class _MiniRaveState extends State<MiniRave> {
  late final RaveAudioHandler _audioHandler;
  bool audioHandlerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    _audioHandler = await AudioService.init(
      builder: () => RaveAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.alexinabox.openrave.channel.audio',
        androidNotificationChannelName: 'Music playback',
      ),
    );

    _audioHandler.addListener(() {
      setState(() {}); // Rebuild when Metadata updates
    });

    _audioHandler.loadAndPlay("J_1lnqs0odU"); // Replace with dynamic video ID
    audioHandlerInitialized = true;
  }

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SelectableText('Room: ${widget.roomCode}'),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.roomCode));
                  // copied successfully
                },
                icon: Icon(
                  Icons.copy,
                  color: Colors.blueAccent,
                  size: 24.0,
                  semanticLabel: 'Copy the room code.',
                ),
              ),
            ],
          ),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      widget.roomCode,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                      child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 18),
                      children: [
                        TextSpan(text: "Artist: "),
                        TextSpan(text: getArtistName()),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Song: "),
                        TextSpan(text: getSongName()),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Is Playing: "),
                        TextSpan(text: getIsPlaying()),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Progress: "),
                        TextSpan(text: getProgressAsString()),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Duration: "),
                        TextSpan(
                          text: getDurationAsString(),
                        ),
                      ],
                    ),
                  )),
                  CupertinoButton.filled(
                    onPressed: () {
                      if (_audioHandler.isPlaying) {
                        _audioHandler.pause();
                      } else {
                        _audioHandler.play();
                      }
                    },
                    child: Text("Play/Pause"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Image.network(
                      getCoverImageUrl(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: CupertinoSlider(
                      value: getAbsoluteProgress(),
                      onChanged: (value) {
                        seekToFromSliderValue(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double getAbsoluteProgress() {
    if (!audioHandlerInitialized) {
      return 0.0;
    }
    return _audioHandler.position.inMilliseconds /
        _audioHandler.video.duration!.inMilliseconds;
  }

  String getCoverImageUrl() {
    if (!audioHandlerInitialized) {
      return "https://placehold.co/400/transparent/transparent/png";
    }
    return "https://yttf.zeitvertreib.vip/?url=${_audioHandler.video.url}";
  }

  String getDurationAsString() {
    if (!audioHandlerInitialized || _audioHandler.video.duration == null) {
      return "Loading...";
    }
    return _audioHandler.video.duration.toString();
  }

  String getProgressAsString() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.position.toString();
  }

  String getIsPlaying() {
    if (!audioHandlerInitialized) return "Loading...";

    return _audioHandler.isPlaying ? "Yes" : "No";
  }

  String getSongName() {
    if (!audioHandlerInitialized) return "Loading...";

    return _audioHandler.video.title;
  }

  String getArtistName() {
    if (!audioHandlerInitialized) return "Loading...";
    // Check if audio player has been initialized yet
    return _audioHandler.video.author;
  }

  void seekToFromSliderValue(double value) {
    _audioHandler.seek(Duration(
        milliseconds:
            (value * _audioHandler.video.duration!.inMilliseconds).toInt()));
  }
}
