import 'dart:convert';
import 'package:http/http.dart' as http;

class Metadata {
  String artistName = "";
  String songTitle = "";
  String coverUrl = "https://placehold.co/400/transparent/transparent/png";
  int duration = 0;
  int progress = 0;
  bool isPlaying = false;

  Future<void> fetchMetadata(String videoId) async {
    // Use this url "https://www.youtube.com/oembed?url=https://music.youtube.com/watch?v=<videoId>" to fetch metadata
    // Replace <videoId> with the actual room code from your database or API
    String url =
        "https://www.youtube.com/oembed?url=https://music.youtube.com/watch?v=$videoId";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      artistName = data['author_name'];
      songTitle = data['title'];
      coverUrl = "https://yttf.zeitvertreib.vip/?url=$url";
      duration = 0;
      progress = 0;
      isPlaying = true;
    } else {
      throw Exception('Failed to fetch metadata');
    }
  }
}
