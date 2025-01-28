import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Rave extends StatefulWidget {
  const Rave({super.key});

  @override
  State<Rave> createState() => _RaveState();
}

class _RaveState extends State<Rave> {
  String _roomCode = '12334';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('OpenRave in Room $_roomCode'),
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
