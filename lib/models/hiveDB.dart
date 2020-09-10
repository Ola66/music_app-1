import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:hive/hive.dart';

part 'hiveDB.g.dart';

@HiveType(typeId: 0)
class MusicModel {

  @HiveField(0)
  final SongInfo song;

  MusicModel({@required this.song});
}
