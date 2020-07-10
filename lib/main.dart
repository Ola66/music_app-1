import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:ologee_music_app/models/get_song_class.dart';
import 'package:ologee_music_app/pages/root_file.dart';
import 'package:provider/provider.dart';

void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//  InitHive().startHive(boxName: 'musicDB')
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider<List<SongInfo>>.value(
      value: GetAllSongOnDevice().getSongs(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RootPage(),
      ),
    );
  }
}
