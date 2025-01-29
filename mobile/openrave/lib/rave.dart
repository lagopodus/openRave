import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Rave extends StatefulWidget {
  const Rave({super.key, required this.roomCode});

  final String roomCode;

  @override
  State<Rave> createState() => _RaveState(roomCode: roomCode);
}

class _RaveState extends State<Rave> {
  final String roomCode;
  _RaveState({required this.roomCode});

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
      child: Center(
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
            ],
          ),
        ),
      ),
    );
  }
}
