import 'package:flutter/cupertino.dart';
import 'rave.dart';
import 'rave.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _random = Random();
  String _roomCode = "";

  String randomRoomCode() {
    String code = "";
    for (int i = 0; i < 6; i++) {
      code += _random.nextInt(10).toString();
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('OpenRave'),
        automaticallyImplyLeading: false,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 250,
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(7),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) => Rave(
                        roomCode: randomRoomCode(),
                      ),
                    ),
                  );
                  return;
                },
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
                          builder: (context) => Rave(
                            roomCode: _roomCode,
                          ),
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
  return double.tryParse(s) != null;
}
