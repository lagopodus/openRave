import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Metadata extends ChangeNotifier {
  String _artistName = "";
  String _songTitle = "";
  String _coverUrl = "https://placehold.co/400/transparent/transparent/png";
  int _duration = 0;
  int _progress = 0;
  bool _isPlaying = false;

  // Getters
  String get artistName => _artistName;
  String get songTitle => _songTitle;
  String get coverUrl => _coverUrl;
  int get duration => _duration;
  int get progress => _progress;
  bool get isPlaying => _isPlaying;

  // Setters with notifyListeners()
  void setPlayingStatus(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  void setProgress(int progress) {
    _progress = progress;
    notifyListeners();
  }

  // Fetch metadata and update properties
  Future<void> fetchMetadata(String videoId) async {
    String url =
        "https://www.youtube.com/oembed?url=https://music.youtube.com/watch?v=$videoId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      _artistName = data['author_name'];
      _songTitle = data['title'];
      _coverUrl = "https://yttf.zeitvertreib.vip/?url=$url";
      _duration = 0;
      _progress = 0;
      _isPlaying = true;

      notifyListeners(); // Notifies all listeners to rebuild
    } else {
      throw Exception('Failed to fetch metadata');
    }
  }
}
