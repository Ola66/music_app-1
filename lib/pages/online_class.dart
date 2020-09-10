import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class OnlineMethods {
//  StreamController<String> controller = StreamController.broadcast();
//  StreamController<bool> isPlayingController = StreamController.broadcast();
  String downloadMessage = 'loading';
  String playingSongTitle = 'none';
  String playingSongArtist = 'none';
  bool isDownloading = false;
  bool isPlaying = false;
  bool isTopSong = false;
  String isPlayingUrl = '';
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'my_unique_playerId');

  Connectivity connectivity;

//  StreamSubscription<ConnectivityResult> subscription;
  bool performOnlineActivity;
  bool toDisplayList = true;

  void streamSong({
    @required String musicUrl,
    @required String name,
    @required String artist,
  }) async {
    try {
      if (audioPlayer.state == AudioPlayerState.PLAYING ||
          audioPlayer.state == AudioPlayerState.PAUSED) {
        await audioPlayer.stop();

        int result = await audioPlayer.play(musicUrl);
//        controller.add(musicUrl);
//
//        playingSongTitle = name;
//        playingSongArtist = artist;
//        isPlayingController.add(true);
//        isPlayingUrl = musicUrl;

        if (result == 1) {
          print('playing.....');

          audioPlayer.onPlayerCompletion.listen((event) {
            audioPlayer.stop();
//            controller.add('');
//            playingSongTitle = 'none';
//            playingSongArtist = 'none';
//
//            isPlayingController.add(false);
            isPlayingUrl = '';
          });
        }
      } else {
        await audioPlayer.stop();
        int result = await audioPlayer.play(musicUrl);
        if (result == 1) {
//          controller.add(musicUrl);
//          playingSongTitle = name;
//          playingSongArtist = artist;
//          isPlayingController.add(true);

          isPlayingUrl = musicUrl;
          print('playing.....');

//          isPlaying = true;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<int> playSong({String url, Map data}) async {
    int result;

    try {
      await OnlineBox().saveOnlineSongInfo(
        duration: data['duration'],
//                          time: widget.data['timeStamp'],
        togSong: data['togSong'],
        artist: data['artist'],
        name: data['name'],
        imageurl: data['imageUrl'],
        url: data['url'],
      );

      print('ttttttttttttttttttttttttttttttttttt');
      print(data);
      print('plaing');
      if (audioPlayer.state == AudioPlayerState.PLAYING ||
          audioPlayer.state == AudioPlayerState.PAUSED) {
        print('plaing');
        await audioPlayer.stop();

        print('plaing');
        await audioPlayer.play(url);

        result = 0;
      } else {
        print('ttttttttttttttttttttttttttttttttttt');
        print(data);
        await audioPlayer.play(url);
        result = 0;
      }
    } catch (e) {
      result = 1;
    }

    return result;
  }

  Future<void> pauseSong() async {
    await audioPlayer.pause();
  }

  Future<void> resumeSong() async {
    await audioPlayer.resume();
  }

  Future<void> stopSong() async {
    await audioPlayer.stop();
    await OnlineBox().isPlaying(status: false);
  }
}

class OnlineBox {
  Future<Box<Map>> getOpenBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<void> saveOnlineSongInfo({
    String duration,
    String name,
    String togSong,
    String artist,
    String imageurl,
    String url,
  }) async {
    Box<Map> box = await getOpenBox('onlineMusicDB');

    Map<dynamic, dynamic> data = {
      'duration': duration,
//      'timeStamp': time,
      'topSong': togSong,
      'artist': artist,
      'name': name,
      'imageUrl': imageurl,
      'url': url,
      'isPlaying': true,
    };

    print(data);
    print('got here');
    await box.put(0, data.cast());
    print('saved');
    print('saved');
    print('RRrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr');
  }

  Future isPlaying({@required bool status}) async {
    Box<Map> box = await getOpenBox('onlineMusicDB');

    Map data = box.getAt(0);
    data['isPlaying'] = status;
    await box.put(0, data.cast());
    print('update');
  }

//  Stream
}
