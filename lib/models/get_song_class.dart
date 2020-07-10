import 'package:flutter_audio_query/flutter_audio_query.dart';

class GetAllSongOnDevice {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  Future<List<SongInfo>> getSongs() async {
    print('start');
    List<SongInfo> _songs = await audioQuery.getSongs();
    print('end');
    print(_songs);
    print(_songs.length);

    return _songs;
  }
}
