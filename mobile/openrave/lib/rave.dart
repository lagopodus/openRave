import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'services/audio_handler.dart';
import 'services/backend_handler.dart';

class Rave extends StatefulWidget {
  Rave({super.key, required this.roomCode});

  final String roomCode;
  final RoomController _roomController = RoomController();
  @override
  State<Rave> createState() => _RaveState();
}

class _RaveState extends State<Rave> {
  late final RaveAudioHandler _audioHandler;
  bool audioHandlerInitialized = false;
  String localRoomCode = "";
  ConnectionState backendConnectionState = ConnectionState.waiting;

  // Search related fields
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  List<Video> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    localRoomCode = widget.roomCode;
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

    _audioHandler.addListener(() {
      setState(() {}); // Rebuild when metadata updates
    });

    await _initWebsocket();

    // Example: preload a default video (if needed)
    // await _audioHandler.loadAndPlay("tVGH-g6OQhg");
  }

  Future<void> _initWebsocket() async {
    widget._roomController.onEvent.listen((event) async {
      if (event.startsWith("catchUp: ")) {
        //"catchUp: uMkBuxEDkyg 104.7096185064935 playing"
        List<String> parts = event.split(' ');

        String videoId = parts[1]; // Assuming videoId is at index 1
        double seekTime =
        double.parse(parts[2]); // Assuming seekTime is at index 2
        String state = parts[3]; // Assuming the state (e.g., "playing") is at index 3
        _audioHandler.catchUp(
            videoId, Duration(milliseconds: (seekTime * 1000).round()), state);

        await _audioHandler.refreshMetadata(videoId);
        audioHandlerInitialized = true;
      } else if (event.startsWith("videoId: ")) {
        String videoId = event.substring(9);
        _audioHandler.loadAndPlay(videoId);
      } else if (event.startsWith("seek: ")) {
        double seekTime = double.parse(event.substring(6));
        _audioHandler.seekNoNotify(
            Duration(milliseconds: (seekTime * 1000).round()));
      } else if (event == "playing") {
        _audioHandler.playNoNotify();
      } else if (event == "paused") {
        _audioHandler.pauseNoNotify();
      } else if (event == "alive") {
        backendConnectionState = ConnectionState.active;
        setState(() {});
      } else if (event == "error") {
        backendConnectionState = ConnectionState.done;
        setState(() {});
      } else if (event == "closed") {
        backendConnectionState = ConnectionState.done;
        setState(() {});
      }
    });

    widget._roomController.initialize(localRoomCode);
  }

  @override
  void dispose() {
    _audioHandler.stop();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Executes a YouTube search using youtube_explode_dart.
  Future<void> _performSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final yt = YoutubeExplode();
    try {
      final videos = await yt.search.getVideos(query);
      final results = videos.take(10).toList();
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle search error appropriately.
      print("Search error: $e");
    } finally {
      yt.close();
    }
  }

  /// Called when a user selects a search result.
  void _selectSearchResult(Video video) {
    // Load and play the selected video.
    _audioHandler.loadAndPlay(video.id.value);
    // Hide the search UI and clear results.
    setState(() {
      _showSearchBar = false;
      _searchResults = [];
      _searchController.clear();
    });
  }

  /// Called on each change in the search text field.
  void _onSearchChanged(String query) {
    // Cancel any existing debounce timer.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Debounce the search to wait for 300ms after the user stops typing.
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Wrap the page content in MediaQuery.removeViewInsets to prevent the keyboard from pushing up the page.
      child: MediaQuery.removeViewInsets(
        removeBottom: true,
        context: context,
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red,
                        child: Center(
                          child: getBackendConnectionInfo(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.75,
                      height: MediaQuery.sizeOf(context).width * 0.75,
                      child: Image.network(
                        fit: BoxFit.cover,
                        getCoverImageUrl(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.78,
                      child: TextScroll(
                        getSongName(),
                        intervalSpaces: 10,
                        velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        mode: TextScrollMode.endless,
                        delayBefore: Duration(milliseconds: 10000),
                        pauseBetween: Duration(milliseconds: 15000),
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.78,
                      child: TextScroll(
                        getArtistName(),
                        intervalSpaces: 10,
                        velocity: Velocity(pixelsPerSecond: Offset(20, 0)),
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        mode: TextScrollMode.endless,
                        delayBefore: Duration(milliseconds: 10000),
                        pauseBetween: Duration(milliseconds: 15000),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          type: MaterialType.transparency,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackShape: RectangularSliderTrackShape(),
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.5,
                                elevation: 0,
                              ),
                              trackHeight: 2,
                              thumbColor: Colors.white,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white38,
                            ),
                            child: Slider(
                              value: getAbsoluteProgress(),
                              onChanged: (value) {
                                seekToFromSliderValueNoNotify(value);
                              },
                              onChangeEnd: (value) {
                                seekToFromSliderValue(value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.78,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getProgressAsStringShort(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              getDurationAsStringShort(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            onPressed: () {
                              // Jump back to the beginning.
                              seekBackToBeginning();
                            },
                            child: Icon(
                              CupertinoIcons.backward_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          // Pause/Play Button
                          CupertinoButton(
                            onPressed: () async {
                              if (_audioHandler.isPlaying) {
                                await _audioHandler.pause();
                              } else {
                                await _audioHandler.play();
                              }
                            },
                            child: Icon(
                              getPauseButtonState(),
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () {
                              // Jump to the end.
                              seekToEnd();
                            },
                            child: Icon(
                              CupertinoIcons.forward_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Search overlay (if enabled)
            if (_showSearchBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                // Adjust height as needed.
                child: Material(
                  color: Colors.black87.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 40.0, left: 10.0, right: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search text field
                        CupertinoTextField(
                          controller: _searchController,
                          placeholder: 'Search YouTube Music...',
                          style: TextStyle(color: Colors.white),
                          placeholderStyle:
                          TextStyle(color: Colors.white54),
                          autofocus: true,
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 10),
                        // Display live search results (if any)
                        _searchResults.isEmpty
                            ? Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            'No results yet.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                            : Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final video = _searchResults[index];
                              return ListTile(
                                leading: Image.network(
                                  video.thumbnails.highResUrl,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  video.title,
                                  style:
                                  TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  video.author,
                                  style: TextStyle(
                                      color: Colors.white54),
                                ),
                                onTap: () =>
                                    _selectSearchResult(video),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText('Room: $localRoomCode'),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: localRoomCode));
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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Toggle the search overlay.
            setState(() {
              _showSearchBar = !_showSearchBar;
              if (!_showSearchBar) {
                _searchResults = [];
                _searchController.clear();
              }
            });
          },
          child: Icon(
            _showSearchBar ? CupertinoIcons.clear : CupertinoIcons.search,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  dynamic getBackendConnectionInfo() {
    if (backendConnectionState == ConnectionState.waiting) {
      return Text(
        "Connecting...",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      );
    } else if (backendConnectionState == ConnectionState.active) {
      return null;
    } else if (backendConnectionState == ConnectionState.done) {
      return Text(
        "Connection lost.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      );
    }
    return null;
  }

  void seekBackToBeginning() {
    if (!audioHandlerInitialized) return;
    _audioHandler.skipToPrevious();
  }

  void seekToEnd() {
    if (!audioHandlerInitialized) return;
    _audioHandler.skipToNext();
  }

  void seekBackForXSeconds(int seconds) {
    if (!audioHandlerInitialized) return;
    if (_audioHandler.position.inSeconds - seconds < 0) {
      _audioHandler.seek(Duration(seconds: 0));
      return;
    }
    _audioHandler.seek(_audioHandler.position - Duration(seconds: seconds));
  }

  void seekForwardForXSeconds(int seconds) {
    if (!audioHandlerInitialized) return;
    if (_audioHandler.position.inSeconds + seconds + 1 >
        _audioHandler.video.duration!.inSeconds) {
      _audioHandler
          .seek(Duration(seconds: _audioHandler.video.duration!.inSeconds));
      return;
    }
    _audioHandler.seek(_audioHandler.position + Duration(seconds: seconds));
  }

  IconData getPauseButtonState() {
    if (!audioHandlerInitialized) {
      return CupertinoIcons.wifi_exclamationmark;
    }
    if (_audioHandler.playbackState.value.processingState ==
        AudioProcessingState.completed) {
      return CupertinoIcons.play_fill;
    }
    return _audioHandler.isPlaying
        ? CupertinoIcons.pause_fill
        : CupertinoIcons.play_fill;
  }

  double getAbsoluteProgress() {
    if (!audioHandlerInitialized) {
      return 0.0;
    }
    double progress = _audioHandler.position.inMilliseconds /
        _audioHandler.video.duration!.inMilliseconds;

    if (progress > 1.0) {
      progress = 1.0;
    } else if (progress < 0.0) {
      progress = 0.0;
    }
    if (_audioHandler.playbackState.value.processingState ==
        AudioProcessingState.completed) {
      progress = 1.0;
    }
    return progress;
  }

  String getCoverImageUrl() {
    if (!audioHandlerInitialized) {
      return "https://placehold.co/1/transparent/transparent/png";
    }
    return "https://yttf.zeitvertreib.vip/?url=${_audioHandler.video.url}";
  }

  String getDurationAsString() {
    if (!audioHandlerInitialized || _audioHandler.video.duration == null) {
      return "Loading...";
    }
    return _audioHandler.video.duration.toString();
  }

  String getDurationAsStringShort() {
    if (!audioHandlerInitialized) return "0:00";

    return formattedTime(timeInSecond: _audioHandler.video.duration!.inSeconds);
  }

  String getProgressAsString() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.position.toString();
  }

  String getProgressAsStringShort() {
    if (!audioHandlerInitialized) return "0:00";
    if (_audioHandler.playbackState.value.processingState ==
        AudioProcessingState.completed) {
      return getDurationAsStringShort();
    }

    return formattedTime(timeInSecond: _audioHandler.position.inSeconds);
  }

  String formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
  }

  String getIsPlaying() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.isPlaying ? "Yes" : "No";
  }

  String getSongName() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.video.title;
  }

  String getArtistName() {
    if (!audioHandlerInitialized) return "Loading...";
    return _audioHandler.video.author;
  }

  void seekToFromSliderValueNoNotify(double value) {
    _audioHandler.pauseNoNotify();
    _audioHandler.seekNoNotify(Duration(
        milliseconds:
        (value * _audioHandler.video.duration!.inMilliseconds).toInt()));
  }

  void seekToFromSliderValue(double value) {
    _audioHandler.pause();
    _audioHandler.seek(Duration(
        milliseconds:
        (value * _audioHandler.video.duration!.inMilliseconds).toInt()));
  }
}
