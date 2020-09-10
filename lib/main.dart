import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:ologee_music_app/models/get_song_class.dart';
import 'package:ologee_music_app/models/hive_db.dart';
import 'package:ologee_music_app/pages/landing_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitHive().startHive(boxName: 'musicDB');
  await InitHive().startHive(boxName: 'onlineMusicDB');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<SongInfo>>.value(
      value: GetAllSongOnDevice().getSongs(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: LandingPage(),
      ),
    );
  }
}
