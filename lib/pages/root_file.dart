import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:ologee_music_app/models/get_song_class.dart';
import 'package:ologee_music_app/pages/now_playing.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  AudioPlayer audioPlayer = AudioPlayer();
  List<SongInfo> songs;
  bool isPlaying = false;
  SongInfo currentSongPlaying;

  void initPlayer() {
//    audioPlayer.setNotification(
//      title: 'playing',
//    );
  }

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<SongInfo> songs = Provider.of<List<SongInfo>>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ologees App'),
      ),
      body: songs != null
          ? Column(
              children: <Widget>[
                Expanded(
                    child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    SongInfo currentSong = songs[index];
                    bool isCurrentSongPlaying =
                        currentSong == currentSongPlaying;

                    return ListTile(
                      onTap: () {
                        print(isCurrentSongPlaying);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NowPlayingPage(
                              currentSongPlaying: songs[index],
                            ),
                          ),
                        );
                      },
                      title: Container(
                        width: 200,
                        child: Text(
                          '${currentSong.title.split('|')[0]}',
                          style: TextStyle(),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      leading: currentSong.albumArtwork != null
                          ? Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  fit: BoxFit.fill,
                                  image: FileImage(
                                    File(currentSong.albumArtwork),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(Icons.music_note),
                              ),
                            ),
                      subtitle: Row(
                        children: <Widget>[
                          Container(
                            width: 100,
                            child: Text(
                              '${currentSong.artist}',
                              style: TextStyle(),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Text(
                              '${currentSong.duration}',
                              style: TextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
//                          isCurrentSongPlaying
//                              ? Container(
//                                  width: 100,
//                                  child: Text(
//                                    'Playing Now..',
//                                    style: TextStyle(),
//                                    overflow: TextOverflow.ellipsis,
//                                  ),
//                                )
//                              : Container(),
                        ],
                      ),
                    );
                  },
                )),
                Container(
                  margin: EdgeInsets.only(bottom: 2.0),
//                  height: 65,
                  width: MediaQuery.of(context).size.width * 0.99,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: currentPlayingSongInfo(
                          imagePath: currentSongPlaying != null
                              ? currentSongPlaying.albumArtwork
                              : songs[0].albumArtwork,
                          songTitle: currentSongPlaying != null
                              ? currentSongPlaying.title
                              : songs[0].title,
                          artistName: currentSongPlaying != null
                              ? currentSongPlaying.artist
                              : songs[0].artist,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          if (isPlaying == true) {
//                      SongClass().pauseSong();
                            if (mounted) {
                              setState(() {
                                isPlaying = false;
                              });
                            }
                          } else {
//                      SongClass().resumeSong();
                            if (mounted) {
                              setState(() {
                                isPlaying = true;
                              });
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          print('tap');
//          print(songs[0]);
//        },
//        child: Icon(Icons.music_note),
//      ),
    );
  }

  Widget currentPlayingSongInfo({
    @required dynamic imagePath,
    @required dynamic songTitle,
    @required dynamic artistName,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(left: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: imagePath != null
                  ? Container(
                      padding: EdgeInsets.only(bottom: 1),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: ClipOval(
                        child: Image(
                          fit: BoxFit.cover,
                          image: FileImage(
                            File(imagePath),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: ClipOval(
                        child: Center(
                          child: Icon(Icons.music_note),
                        ),
                      ),
                    ),
            ),
            Container(
              margin: EdgeInsets.only(left: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: songTitle != null
                        ? Text(
                            'Playing $songTitle',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Container(),
                  ),
                  Container(
                      child: Text(
                    'By $artistName',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget futureList() {
    return FutureBuilder(
      future: GetAllSongOnDevice().getSongs(),
      builder: (context, snapshot) {
        List<SongInfo> songs = snapshot.data;
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              if (songs.length == 0 || songs == null) {
                return CircularProgressIndicator();
              }
              SongInfo currentSong = songs[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NowPlayingPage(
                        currentSongPlaying: songs[index],
                      ),
                    ),
                  );
                },
                title: Container(
                  width: 200,
                  child: Text(
                    '${currentSong.title.split('|')[0]}',
                    style: TextStyle(),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
                leading: currentSong.albumArtwork != null
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            fit: BoxFit.fill,
                            image: FileImage(
                              File(currentSong.albumArtwork),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.music_note),
                        ),
                      ),
                subtitle: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        '${currentSong.artist}',
                        style: TextStyle(),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    Container(
                      width: 100,
                      child: Text(
                        '${currentSong.duration}',
                        style: TextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
