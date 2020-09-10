import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ologee_music_app/pages/all_latest_song_page.dart';
import 'package:ologee_music_app/pages/online_class.dart';
import 'package:ologee_music_app/pages/selected_online_song.dart';

import 'all_new_release_page.dart';

class OnlineStore extends StatefulWidget {
  @override
  _OnlineStoreState createState() => _OnlineStoreState();
}

class _OnlineStoreState extends State<OnlineStore>
    with AutomaticKeepAliveClientMixin<OnlineStore> {
  StreamController<String> controller = StreamController.broadcast();
  StreamController<bool> isPlayingController = StreamController.broadcast();
  String downloadMessage = 'loading';
  String playingSongTitle = 'none';
  String playingSongArtist = 'none';
  bool isDownloading = false;
  bool isPlaying = false;
  bool isTopSong = false;
  String isPlayingUrl = '';
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'my_unique_playerId');

  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  bool performOnlineActivity;
  bool toDisplayList = true;

//  bool isPlaying = false;
  Box onlineSongBox;
  bool loading = true;

//  BannerAd myBanner;

  //

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

//  BannerAd buildBannerAd() {
//    return BannerAd(
//        adUnitId: BannerAd.testAdUnitId,
//        size: AdSize.banner,
//        listener: (MobileAdEvent event) {
//          if (event == MobileAdEvent.loaded) {
//            myBanner..show();
//          }
//        });
//  }
//
//  BannerAd buildLargeBannerAd() {
//    return BannerAd(
//        adUnitId: BannerAd.testAdUnitId,
//        size: AdSize.largeBanner,
//        listener: (MobileAdEvent event) {
//          if (event == MobileAdEvent.loaded) {
//            myBanner
//              ..show(
//                  anchorType: AnchorType.top,
//                  anchorOffset: MediaQuery.of(context).size.height * 0.15);
//          }
//        });
//  }

  @override
  void initState() {
    getBox();
    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        performOnlineActivity = true;
        toDisplayList = true;
        setState(() {});
      } else if (result == ConnectivityResult.none) {
        performOnlineActivity = false;
        toDisplayList = false;
        setState(() {});
      }
    });
//    FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
//    myBanner = buildBannerAd()..load();
//    //myBanner = buildLargeBannerAd()..load();
    super.initState();
  }

  @override
  void dispose() {
    if (isPlaying == true) {
      audioPlayer.stop();
    }
    controller.close();
    isPlayingController.close();
    subscription.cancel();
    OnlineMethods().stopSong();

    //dispose banner add
//    myBanner.dispose();

    super.dispose();
  }

  Future<List<Map>> getTopSongs() async {
    List<Map> list = List<Map>();

    try {
      await Firestore.instance
          .collection('music')
          .where('topSong', isEqualTo: true)
          .orderBy('name')
          .limit(4)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
//          print(element.data);
          list.add(element.data);
        });
      });
    } catch (e) {
      print(e);
    }

    return list;
  }

  Future<List<Map>> getLatestSongs() async {
    List<Map> _list = List<Map>();

    try {
      await Firestore.instance
          .collection('music')
          .orderBy('timeStamp')
          .limit(4)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          print('oooooooooooooooooooyyyyyyyyyyyyyy');
          print(element.data);
          _list.add(element.data);
        });
      });
    } catch (e) {
      print(e);
    }

    print('rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
    print(_list);
    return _list;
  }

  Widget topContainer() {
    return FutureBuilder(
      future: getTopSongs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          List<Map> topSongList = snapshot.data;
          if (topSongList.isEmpty) {
            return Center(child: Text('No Top Songs Found'));
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: topSongList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.15,
                crossAxisCount: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                Map data = topSongList[index];
                return InkWell(
                  onTap: () {
                    print(data);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SelectedSongPage(data: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
//                      border: Border.all(
//                        color: Colors.black,
//                      ),
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            child: Image.network(
                              data['imageUrl'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data['name'].trim(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                data['artist'].trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  Widget latestContainer() {
    return FutureBuilder(
      future: getLatestSongs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
              height: 180, child: Center(child: CircularProgressIndicator()));
        } else {
          List<Map> latestSongList = snapshot.data;
          if (latestSongList.isEmpty) {
            return Center(child: Text('No Latest Songs Found'));
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: latestSongList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.15,
                crossAxisCount: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                Map data = latestSongList[index];
                return InkWell(
                  onTap: () {
                    print(data);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SelectedSongPage(data: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
//                      border: Border.all(
//                        color: Colors.black,
//                      ),
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            child: Image.network(
                              data['imageUrl'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data['name'].trim(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                data['artist'].trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: toDisplayList
          ? Container(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        ListView(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Top Songs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      //
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllNewReleasePage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'See All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            topContainer(),
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Latest Songs',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      //
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ALlLatestSongPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'See All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            latestContainer(),
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: currentlyPlaying(),
                        ),
                      ],
                    ),
            )
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.signal_wifi_off,
                    color: Colors.grey,
                    size: 80,
                  ),
                  Text(
                    'No Internet Connection Found',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;

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
            if(box.isEmpty){
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
