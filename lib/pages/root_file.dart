import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ologee_music_app/models/hive_db.dart';
import 'package:ologee_music_app/pages/now_playing.dart';
import 'package:ologee_music_app/pages/online_class.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  List<SongInfo> songs;
  bool isPlaying = false;
  bool loading = false;
  SongInfo currentSongPlaying;
  Box<Map> musicBox;

  Directory rootPath;

  PageController _controller = PageController(
    initialPage: 0,
  );

  Future<void> initPlayer() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });
    musicBox = await OnlineBox().getOpenBox('musicDB');
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    initPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<SongInfo> songs = Provider.of<List<SongInfo>>(context);

    return Scaffold(
//      backgroundColor: Colors.teal,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : tarckPage(songs: songs),
    );
  }

  Widget tarckPage({@required List<SongInfo> songs}) {
    return Column(
      children: <Widget>[
        Flexible(
          child: Container(
//            decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.only(
//                topRight: Radius.circular(25),
//                topLeft: Radius.circular(25),
//              ),
//            ),
            child: songs != null
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      SongInfo currentSong = songs[index];
                      return Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {
                                SongInfo lastedSongPlayed = songs[index];
                                int key = 0;

                                HiveMethods().saveLastSongPlayedInfoToBox(
                                    song: lastedSongPlayed);

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
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              leading: currentSong.albumArtwork != null
                                  ? Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
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
                                        color: Colors.white,
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.music_note),
                                      ),
                                    ),
                              subtitle: Container(
                                width: 100,
                                child: Text(
                                  '${currentSong.artist}',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              trailing: Container(
//                                decoration: BoxDecoration(
//                                  border: Border.all(color: Colors.white),
//                                  color: Colors.grey[200],
//                                  borderRadius: BorderRadius.circular(10.0),
//                                ),
                                child: Container(
                                  margin: EdgeInsets.all(5.0),
                                  child: Text(
                                    '${((int.parse(currentSong.duration) / 1000) / 60).toStringAsFixed(1).replaceAll('.', ':')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              left: 5,
              right: 5,
//              bottom: 5,
            ),
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
              ),
//              border: Border.all(color: Colors.black),
            ),
            child: ValueListenableBuilder(
              valueListenable: musicBox.listenable(),
              builder: (context, box, widget) {
                String key = 'BoxOne';
                print('oooooooooooooooooooooooooooooooooooooooooo');
                print(box.get(key));
                if (box.get(key) == null) {
                  return GestureDetector(
                    onTap: () {
                      SongInfo _song = songs[0];
                      print(_song);

                      HiveMethods().saveLastSongPlayedInfoToBox(song: _song);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NowPlayingPage(
                            currentSongPlaying: _song,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Center(child: Text('Tap To Start Playing!')),
                    ),
                  );
                } else {
                  String songTitle = box.get(key)['songTitle'];
                  String artistName = box.get(key)['songArtist'];
                  String imagePath = box.get(key)['songAlbumArtwork'];

                  print(
                      'uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu');
                  print(songTitle);
                  print(artistName);
                  print(imagePath);

                  return GestureDetector(
                    onTap: () {
                      if (box.get(key) == null) {
                        print('pls select song!!');
                        return;
                      } else {
                        SongInfo _song = songs
                            .where((element) =>
                                element.title == songTitle &&
                                element.artist == artistName)
                            .toList()[0];
                        print(_song);

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NowPlayingPage(
                              currentSongPlaying: _song,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: imagePath != null
                              ? Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.black),
                                    ),
                                    margin: EdgeInsets.all(5),
                                    width: 40,
                                    height: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: FileImage(File(imagePath)),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.all(5),
                                  width: 40,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.music_note,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${songTitle.split('|')[0]}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  'By $artistName',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
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
}
