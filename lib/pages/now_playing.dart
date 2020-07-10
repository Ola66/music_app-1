import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:provider/provider.dart';

class NowPlayingPage extends StatefulWidget {
  SongInfo currentSongPlaying;

  NowPlayingPage({
    @required this.currentSongPlaying,
  });

  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  List<SongInfo> songs;
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'my_unique_playerId');
  bool isPlaying = false;
  bool isLiked = false;
  bool mute = false;
  bool shuffle = false;
  double value = 0;
  Duration currentDuration = Duration();
  Duration totalDuration = Duration();

  @override
  void initState() {
//    WidgetsBinding.instance.addPostFrameCallback((_) {
//      initSong();
//    });
    initSong();
    super.initState();
  }

  void initSong() {
    try {
      playSong();
      initOnPlayerCompletion();
      initOnPlayerError();
      initOnDurationChanged();
      initOnAudioPositionChanged();
//      print(getCurrentPlayingSongIndex());
    } catch (e) {
      print(e);
    }
  }

  void initOnPlayerCompletion() {
    audioPlayer.onPlayerCompletion.listen((event) {
      print('done plaing ${widget.currentSongPlaying.title}');
      setState(() {
        currentDuration = Duration();
        totalDuration = Duration();
      });
      playNextSong();
    });
  }

  void initOnPlayerError() {
    audioPlayer.onPlayerError.listen((event) {
      print('Error: $event}');
    });
  }

  void initOnDurationChanged() {
    audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() => totalDuration = d);
      }
    });
  }

  void initOnAudioPositionChanged() {
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
//      print('Current position: $p');
      if (mounted) {
        setState(() => currentDuration = p);
      }
    });
  }

  Future<int> playSong() async {
    if (audioPlayer.state == AudioPlayerState.PLAYING) {
      stopSong();
      if (mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    }

    int status = await audioPlayer.play(
      widget.currentSongPlaying.filePath,
      isLocal: true,
    );

    if (mounted) {
      setState(() {
        isPlaying = true;
      });
    }

    return status;
  }

  Future<int> pauseSong() async {
    print('pausing');
    int status = await audioPlayer.pause();

    if (mounted) {
      setState(() {
        isPlaying = false;
      });
    }

    return status;
  }

  Future<int> resumeSong() async {
    print('resuming');
    int status = await audioPlayer.resume();

    if (mounted) {
      setState(() {
        isPlaying = true;
      });
    }

    return status;
  }

  Future<int> stopSong() async {
    int status = await audioPlayer.stop();

    return status;
  }

  void seekToInSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  void playNextSong() {
    if (shuffle) {
      int index = getRandomIndex();
      widget.currentSongPlaying = songs[index];

      playSong();
    } else {
      int currentSongIndex = songs.indexOf(widget.currentSongPlaying);

      if (currentSongIndex == songs.length - 1) {
        widget.currentSongPlaying =
            songs[currentSongIndex - (songs.length - 1)];
      } else {
        widget.currentSongPlaying = songs[currentSongIndex + 1];
      }

      playSong();
    }
  }

  void playPreviousSong() {
    if (shuffle) {
      int index = getRandomIndex();
      widget.currentSongPlaying = songs[index];

      playSong();
    } else {
      int currentSongIndex = songs.indexOf(widget.currentSongPlaying);

      if (currentSongIndex == 0) {
        widget.currentSongPlaying = widget.currentSongPlaying;
      } else {
        widget.currentSongPlaying = songs[currentSongIndex - 1];
      }

      playSong();
    }
  }

  int getCurrentPlayingSongIndex() {
    int index = songs.indexOf(widget.currentSongPlaying);

    return index;
  }

  int getRandomIndex() {
    Random random = Random();
    int randomIndex = random.nextInt(songs.length - 1);

    return randomIndex;
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final List<SongInfo> _songs = Provider.of<List<SongInfo>>(context);
    setState(() {
      songs = _songs;
    });

    return Scaffold(
      appBar: appbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          trackImage(),
          optionsIcons(),
          songInfo(),
          Expanded(child: Container()),
          songSlider(),
          songControl(),
        ],
      ),
    );
  }

  Widget optionsIcons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  isLiked = !isLiked;
                });
              }
            },
            child: Icon(
              Icons.favorite_border,
              color: isLiked ? Colors.orangeAccent : Colors.grey,
              size: 30,
            ),
          ),
          SizedBox(width: 30),
          InkWell(
            onTap: () async {
              if (!mute) {
                int result = await audioPlayer.setVolume(0.0);

                if (mounted) {
                  setState(() {
                    mute = true;
                  });
                }
              } else {
                int result = await audioPlayer.setVolume(1.0);
                if (mounted) {
                  setState(() {
                    mute = false;
                  });
                }
              }
            },
            child: Icon(
              mute ? Icons.volume_off : Icons.volume_up,
              color: mute ? Colors.orangeAccent : Colors.grey,
              size: 30,
            ),
          ),
          SizedBox(width: 30),
          InkWell(
            onTap: () async {
              if (mounted) {
                setState(() {
                  shuffle = !shuffle;
                });
              }
            },
            child: Icon(
              Icons.shuffle,
              color: shuffle ? Colors.orangeAccent : Colors.grey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget songSlider() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.red[700],
              inactiveTrackColor: Colors.red[100],
              trackShape: RectangularSliderTrackShape(),
              trackHeight: 4.0,
              thumbColor: Colors.redAccent,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayColor: Colors.red.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              min: 0.0,
              max: totalDuration.inSeconds.toDouble(),
              value: currentDuration.inSeconds.toDouble(),
              onChanged: (_value) {
                setState(() {
                  seekToInSeconds(_value.toInt());
                  value = _value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${formatDuration(currentDuration)}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '${formatDuration(totalDuration)}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget songControl() {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(),
          InkWell(
            onTap: () {
              playPreviousSong();
            },
            child: Icon(
              Icons.skip_previous,
              color: Colors.grey,
              size: 50,
            ),
          ),
          InkWell(
            onTap: () {
              print('pressed');
              if (isPlaying) {
                pauseSong();
              } else {
                resumeSong();
              }
            },
            child: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.orangeAccent,
              size: 70,
            ),
          ),
          InkWell(
            onTap: () {
              playNextSong();
            },
            child: Icon(
              Icons.skip_next,
              color: Colors.grey,
              size: 50,
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }

  Widget songInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        children: <Widget>[
          Text(
            '${widget.currentSongPlaying.artist}',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${widget.currentSongPlaying.title.split('|')[0]}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget trackImage() {
    if (widget.currentSongPlaying.albumArtwork != null) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(10),
          height: 220,
          width: MediaQuery.of(context).size.width * 0.55,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              fit: BoxFit.cover,
              image: FileImage(File(widget.currentSongPlaying.albumArtwork)),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 220,
        width: MediaQuery.of(context).size.width * 0.55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Icon(Icons.music_note),
        ),
      );
    }
  }

  AppBar appbar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
