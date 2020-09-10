import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class InitHive {
  Future<void> startHive({@required String boxName}) async {
    Directory documentDir = await getApplicationSupportDirectory();
    Hive.init(documentDir.path);
//    Hive.registerAdapter(MusicModelAdapter());
    await Hive.openBox<Map>(boxName);
  }

//  Future<void> startHive1({@required String boxName}) async {
//    Directory documentDir = await getApplicationSupportDirectory();
//    Hive.init(documentDir.path);
//    await Hive.openBox<SongInfo>(boxName);
//  }
}

class HiveMethods {
  Box<Map> musicBox = Hive.box<Map>('musicDB');

  void saveLastSongPlayedInfoToBox({@required SongInfo song}) {
    String key = 'BoxOne';
    Map value = HiveDbModel(lastedPlayedSong: song).getInfoToSave();

    musicBox.put(key, value);
    print('saved');
  }

  Map getLastSongPlayedInfoSavedToBox() {
    String key = 'BoxOne';
    Map song = musicBox.get(key);

    return song;
  }

//  Stream<Map> getCurrentSong(){
//    musicBox.
//  }

  void saveShuffleInfoToBox() {
    String key = 'shuffle';

    if (getShuffleInfoSavedToBox() != null &&
        getShuffleInfoSavedToBox()['isShuffle'] == false) {
      Map value = {'isShuffle': true};
      musicBox.put(key, value);
      print('save shu');
    } else {
      Map value = {'isShuffle': false};
      musicBox.put(key, value);
      print('save shu');
    }
  }

  Map getShuffleInfoSavedToBox() {
    String key = 'shuffle';
    Map value = musicBox.get(key);

    print(value);
    return value;
  }
}

class HiveDbModel {
  final SongInfo lastedPlayedSong;

  HiveDbModel({@required this.lastedPlayedSong});

  Map getInfoToSave() {
    Map _map = {
      'songTitle': lastedPlayedSong.title,
      'songArtist': lastedPlayedSong.artist,
      'songAlbumArtwork': lastedPlayedSong.albumArtwork,
      'songAlbum': lastedPlayedSong.album,
      'songDuration': lastedPlayedSong.duration,
      'songFilePath': lastedPlayedSong.filePath,
      'songId': lastedPlayedSong.id,
    };

    return _map;
  }
}
