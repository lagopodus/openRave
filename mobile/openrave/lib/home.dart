import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _roomCode = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('OpenRave'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 250,
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(7),
                onPressed: () {},
                child: const Text('Start a Rave'),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CupertinoTextField(
                    maxLength: 6,
                    maxLines: 1,
                    spellCheckConfiguration: SpellCheckConfiguration.disabled(),
                    placeholder: '012345',
                    onChanged: (value) {
                      setState(() {
                        _roomCode = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(7),
                  onPressed: () {},
                  child: const Text('Join a Rave!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
