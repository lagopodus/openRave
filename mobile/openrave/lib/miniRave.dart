import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'audio_handler.dart';

class MiniRave extends StatefulWidget {
  const MiniRave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<MiniRave> createState() => _MiniRaveState();
}

class _MiniRaveState extends State<MiniRave> {
  late final RaveAudioHandler _audioHandler;

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

    _audioHandler.loadAndPlay("itrXvuMArYs"); // Replace with dynamic video ID
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
        middle: Text('Room: ${widget.roomCode}'),
      ),
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () {
            _audioHandler.play();
          },
          child: Text("Play Audio"),
        ),
      ),
    );
  }
}
