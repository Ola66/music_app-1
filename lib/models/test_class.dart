//import 'package:audioplayers/audioplayers.dart';
//import 'package:flutter_audio_query/flutter_audio_query.dart';
//
//class SongClass {
//  final AudioPlayer audioPlayer = AudioPlayer();
//  final SongInfo presentSong;
//
//  SongClass({this.presentSong});
//
//  playSong() async {
////    if (audioPlayer.state == AudioPlayerState.PLAYING) {
////      stopSong();
////    if (status == 1) {
////      print('ended sucessfully!');
////    } else {
////      print('unable to end song');
////    }
////    }
////
//    presentSong = presentSong;
//    int status = await audioPlayer.play(
//      presentSong.filePath,
//      isLocal: true,
//    );
//
////    return;
//  }
//
//  String getState() {
//    if (audioPlayer.state == AudioPlayerState.PLAYING) {
//      return 'playing';
//    } else if (audioPlayer.state == AudioPlayerState.PAUSED) {
//      return 'paused';
//    } else if (audioPlayer.state == AudioPlayerState.STOPPED) {
//      return 'stopped';
//    } else if (audioPlayer.state == AudioPlayerState.COMPLETED) {
//      return 'complete';
//    } else {
//      return 'null';
//    }
//  }
//
//  Future<int> stopSong() async {
//    int status = await audioPlayer.stop();
//    print('stop..............');
//
//    return status;
//  }
//
//  Future<int> pauseSong() async {
//    int status = await audioPlayer.pause();
//
//    return status;
//  }
//
//  Future<int> resumeSong() async {
//    int status = await audioPlayer.resume();
//
//    return status;
//  }
//
//  SongInfo get currentSong {
//    return presentSong;
//  }
//}
