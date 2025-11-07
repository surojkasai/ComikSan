// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comic.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComicAdapter extends TypeAdapter<Comic> {
  @override
  final int typeId = 0;

  @override
  Comic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comic(
      id: fields[0] as int,
      title: fields[1] as String,
      author: fields[2] as String,
      genre: fields[3] as String,
      lastSynced: fields[4] as DateTime,
      followerCount: fields[5] as int,
      mangaDexId: fields[6] as String?,
      description: fields[7] as String?,
      coverImageUrl: fields[8] as String?,
      chapters: (fields[9] as List).cast<Chapter>(),
    );
  }

  @override
  void write(BinaryWriter writer, Comic obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.genre)
      ..writeByte(4)
      ..write(obj.lastSynced)
      ..writeByte(5)
      ..write(obj.followerCount)
      ..writeByte(6)
      ..write(obj.mangaDexId)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.coverImageUrl)
      ..writeByte(9)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
