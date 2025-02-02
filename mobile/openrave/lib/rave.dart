import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio_handler.dart';
import 'package:text_scroll/text_scroll.dart';

class Rave extends StatefulWidget {
  const Rave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<Rave> createState() => _RaveState();
}

class _RaveState extends State<Rave> {
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

    _audioHandler.loadAndPlay("zPV7XhU2Obo"); // Replace with dynamic video ID
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
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.75,
                    height: MediaQuery.sizeOf(context).width * 0.75,
                    child: Image.network(
                      getCoverImageUrl(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.78,
                    child: TextScroll(
                      getSongName(),
                      intervalSpaces: 10,
                      velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      mode: TextScrollMode.endless,
                      delayBefore: Duration(milliseconds: 10000),
                      pauseBetween: Duration(milliseconds: 15000),
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.78,
                    child: TextScroll(
                      getArtistName(),
                      intervalSpaces: 10,
                      velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      mode: TextScrollMode.endless,
                      delayBefore: Duration(milliseconds: 10000),
                      pauseBetween: Duration(milliseconds: 15000),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: SizedBox(
                      height: 20,
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        type: MaterialType.transparency,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackShape: RectangularSliderTrackShape(),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 6.5,
                              elevation: 0,
                            ),
                            trackHeight: 2,
                            thumbColor: Colors.white,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white38,
                          ),
                          child: Slider(
                            value: getAbsoluteProgress(),
                            onChanged: (value) {
                              seekToFromSliderValue(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.78,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getProgressAsStringShort(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            getDurationAsStringShort(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            _audioHandler.seek(
                                _audioHandler.position - Duration(seconds: 10));
                          },
                          child: Icon(
                            CupertinoIcons.backward_fill,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        //Pause Play Button
                        CupertinoButton(
                          onPressed: () async {
                            if (_audioHandler.isPlaying) {
                              await _audioHandler.pause();
                            } else {
                              await _audioHandler.play();
                            }
                          },
                          child: Icon(
                            getPauseButtonState(),
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            _audioHandler.seek(
                                _audioHandler.position + Duration(seconds: 10));
                          },
                          child: Icon(
                            CupertinoIcons.forward_fill,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getPauseButtonState() {
    if (!audioHandlerInitialized) {
      return CupertinoIcons.wifi_exclamationmark;
    }
    return _audioHandler.isPlaying
        ? CupertinoIcons.pause_fill
        : CupertinoIcons.play_fill;
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
      return "https://placehold.co/1/transparent/transparent/png";
    }
    return "https://yttf.zeitvertreib.vip/?url=${_audioHandler.video.url}";
  }

  String getDurationAsString() {
    if (!audioHandlerInitialized || _audioHandler.video.duration == null) {
      return "Loading...";
    }
    return _audioHandler.video.duration.toString();
  }

  String getDurationAsStringShort() {
    if (!audioHandlerInitialized) return "0:00";

    return formattedTime(timeInSecond: _audioHandler.video.duration!.inSeconds);
  }

  String getProgressAsString() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.position.toString();
  }

  String getProgressAsStringShort() {
    if (!audioHandlerInitialized) return "0:00";

    return formattedTime(timeInSecond: _audioHandler.position.inSeconds);
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
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
    _audioHandler.pause();
    _audioHandler.seek(Duration(
        milliseconds:
            (value * _audioHandler.video.duration!.inMilliseconds).toInt()));
  }
}
