import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'rave.dart';

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
                  onPressed: () {
                    //If the room code is of valid lenght (6) and has digits only, then proceed to join the rave.
                    if (_roomCode.length == 6 && isNumeric(_roomCode)) {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (context) => const Rave(),
                        ),
                      );
                      return;
                    } else {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Invalid Room Code'),
                            content: Text(
                                'The room code you entered is not valid. Please try again.'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
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

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
