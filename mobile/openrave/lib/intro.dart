import 'package:flutter/cupertino.dart';
import 'home.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final List<String> _texts = [
    "Welcome to OpenRave!",
    "OpenRave is a platform to enjoy music together.",
    "It works like other tools you might know, such as Watch2Gether or Rave™.",
    "Create a room, invite friends, and listen to music in sync.",
    "Experience the joy of shared playlists and real-time music sessions.",
    "Start your journey of synchronized music enjoyment now!"
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('OpenRave'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  _texts[0],
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 200),
              Hero(
                tag: 'continueButton',
                child: CupertinoButton.filled(
                  onPressed: () {
                    setState(() {
                      if (_texts.length == 1) {
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (context) => const Home(),
                          ),
                        );
                        return;
                      }
                      _texts.removeAt(0);
                    });
                  },
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
