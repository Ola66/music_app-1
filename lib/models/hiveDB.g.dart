// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hiveDB.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicModelAdapter extends TypeAdapter<MusicModel> {
  @override
  MusicModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MusicModel(
      song: fields[0] as SongInfo,
    );
  }

  @override
  void write(BinaryWriter writer, MusicModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.song);
  }

  @override
  // TODO: implement typeId
  int get typeId => 0;
}
