import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ologee_music_app/pages/online_class.dart';

class SelectedSongPage extends StatefulWidget {
  final Map data;

  SelectedSongPage({@required this.data});

  @override
  _SelectedSongPageState createState() => _SelectedSongPageState();
}

class _SelectedSongPageState extends State<SelectedSongPage> {
  bool isPlaying = false;
  Box onlineSongBox;
  bool loading = true;

  Future<void> getBox() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    onlineSongBox = await OnlineBox().getOpenBox('onlineMusicDB');

    setState(() {
      loading = false;
    });
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(2, '0');
  }

  @override
  void initState() {
    getBox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.all(15.0),
                        height: 220,
                        width: 190,
//            color: Colors.grey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                          child: Image.network(
                            widget.data['imageUrl'],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0, left: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.data['artist'].trim(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.data['name'].trim(),
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.data['duration'].trim()} Mins',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    InkWell(
                      onTap: () async {
//                        print('0000000000000000000000000000000000000000000000000');
                        await OnlineMethods().playSong(
                          url: widget.data['url'],
                          data: widget.data,
                        );
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * .50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orange,
                        ),
                        child: Center(
                          child: Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    InkWell(
                      onTap: () async {
                        await OnlineMethods().stopSong();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * .50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orange,
                        ),
                        child: Center(
                          child: Text(
                            'stop',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                currentlyPlaying(),
              ],
            ),
    );
  }

  Widget currentlyPlaying() {
    return Container(
      color: Colors.white,
      child: Container(
        child: ValueListenableBuilder(
          valueListenable: onlineSongBox.listenable(),
          builder: (context, Box box, widget) {
            int key = 0;
            print('oooooooooooooooooooooooooooooooooooooooooo');
            print(box.get(key));
            if (box.isEmpty) {
              return Container(
                height: 0.0,
              );
            }

            print(box.get(key).toString());
            if (box.getAt(key) == null) {
              return GestureDetector(
                child: Container(),
              );
            } else {
              String songTitle = box.getAt(key)['name'];
              String artistName = box.getAt(key)['artist'];
              String imagePath = box.getAt(key)['imageurl'];
              bool isPlaying = box.getAt(key)['isPlaying'];

              if (isPlaying == false) {
                return Container(
//                  padding: EdgeInsets.only(
//                    left: 5,
//                    right: 5,
//                  ),
//                  width: double.infinity,
                  height: 0,
//                  decoration: BoxDecoration(
//                    color: Colors.orange,
//                    borderRadius: BorderRadius.only(
//                      topRight: Radius.circular(20.0),
//                      topLeft: Radius.circular(20.0),
//                    ),
//                  ),
                );
              } else {
                return Visibility(
                  visible: box.getAt(key)['isPlaying'],
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                    ),
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
                                        image: NetworkImage(imagePath),
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
                        Container(
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                    onTap: () async {
                                      await OnlineMethods().pauseSong();
                                    },
                                    child: Icon(Icons.pause)),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                    onTap: () async {
                                      await OnlineMethods().resumeSong();
                                    },
                                    child: Icon(Icons.play_arrow)),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: InkWell(
                                    onTap: () async {
                                      await OnlineMethods().stopSong();
                                    },
                                    child: Icon(Icons.stop)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: StreamBuilder(
                            stream: OnlineMethods()
                                .audioPlayer
                                .onAudioPositionChanged,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return CircularProgressIndicator(
                                    strokeWidth: 2.0);
                              } else {
                                return Text('');
//                                return Text('${formatDuration(snap.data)}');
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
