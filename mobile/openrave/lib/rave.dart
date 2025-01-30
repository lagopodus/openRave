import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Rave extends StatefulWidget {
  const Rave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<Rave> createState() => _RaveState(roomCode: roomCode);
}

class _RaveState extends State<Rave> {
  final String roomCode;
  _RaveState({required this.roomCode});

  static String myVideoId = "cQjW6OOpo4g";

  final YoutubePlayerBuilder _playerBuilder = YoutubePlayerBuilder(
    builder: (p0, p1) => p1,
    player: YoutubePlayer(
      controller: YoutubePlayerController(
        initialVideoId: myVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();

    _playerBuilder.player.controller.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild when Metadata updates
      }
    });
  }

  @override
  void dispose() {
    _playerBuilder.player.controller
        .removeListener(() {}); // Remove listener to prevent memory leaks
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
              SelectableText('Room: $roomCode'),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: roomCode));
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
          SizedBox(
            width: 0,
            height: 0,
            child: _playerBuilder,
          ), // Invisible
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      roomCode,
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
                        TextSpan(
                            text: _playerBuilder
                                .player.controller.metadata.author),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Song: "),
                        TextSpan(
                            text: _playerBuilder
                                .player.controller.metadata.title),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Is Playing: "),
                        TextSpan(
                            text:
                                _playerBuilder.player.controller.value.isPlaying
                                    ? "Yes"
                                    : "No"),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Progress: "),
                        TextSpan(
                          text: _playerBuilder.player.controller.value.position
                              .toString(),
                        ),
                        TextSpan(text: "\n"),
                        TextSpan(text: "Duration: "),
                        TextSpan(
                          text: _playerBuilder
                              .player.controller.metadata.duration
                              .toString(),
                        ),
                      ],
                    ),
                  )),
                  CupertinoButton.filled(
                    onPressed: () {
                      _playerBuilder.player.controller.value.isPlaying
                          ? _playerBuilder.player.controller.pause()
                          : _playerBuilder.player.controller.play();
                    },
                    child: Text("Play/Pause"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Image.network(
                      _playerBuilder.player.controller.metadata.videoId == ""
                          ? "https://placehold.co/400/transparent/transparent/png"
                          : "https://yttf.zeitvertreib.vip/?url=https://music.youtube.com/watch?v=${_playerBuilder.player.controller.metadata.videoId}",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: CupertinoSlider(
                      value: getProgressAbsolute(),
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

  void seekToFromSliderValue(double value) {
    _playerBuilder.player.controller.seekTo(Duration(
        milliseconds: (value *
                _playerBuilder
                    .player.controller.metadata.duration.inMilliseconds)
            .toInt()));
  }

  double getProgressAbsolute() {
    return _playerBuilder.player.controller.value.position.inMilliseconds == 0
        ? 0
        : _playerBuilder.player.controller.value.position.inMilliseconds /
            _playerBuilder.player.controller.metadata.duration.inMilliseconds;
  }
}
