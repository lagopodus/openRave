import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'helper/metadata.dart';

class Rave extends StatefulWidget {
  const Rave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<Rave> createState() => _RaveState(roomCode: roomCode);
}

class _RaveState extends State<Rave> {
  final String roomCode;
  _RaveState({required this.roomCode});

  static String myVideoId = "NFw-FrYmAEw";

  Metadata _metadata = Metadata();

  @override
  void initState() {
    super.initState();
    _metadata.fetchMetadata(myVideoId).then((metadata) {
      setState(() {
        _metadata = _metadata;
      });
    });
  }

  final YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: myVideoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
    ),
  );

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
            child: YoutubePlayer(
              controller: _controller,
              liveUIColor: Colors.amber,
            ),
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
                    child: Text(
                      _metadata.artistName,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Image.network(
                      _metadata.coverUrl,
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
}
