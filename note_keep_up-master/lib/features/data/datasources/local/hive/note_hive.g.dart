// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteHiveAdapter extends TypeAdapter<NoteHive> {
  @override
  final int typeId = 0;

  @override
  NoteHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteHive(
      userId: fields[11] as String,
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      colorIndex: fields[3] as int,
      createdAt: fields[4] as DateTime,
      modifiedTime: fields[5] as DateTime,
      stateNoteHive: fields[6] as StateNoteHive,
      taskStatus: fields[7] as int,
      isCompleted: fields[8] as bool,
      deadline: fields[9] as DateTime?,
      reminder: fields[10] as ReminderHive?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.colorIndex)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.modifiedTime)
      ..writeByte(6)
      ..write(obj.stateNoteHive)
      ..writeByte(7)
      ..write(obj.taskStatus)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.deadline)
      ..writeByte(10)
      ..write(obj.reminder)
      ..writeByte(11)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
