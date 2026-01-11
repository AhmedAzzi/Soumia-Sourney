// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTaskAdapter extends TypeAdapter<RecurringTask> {
  @override
  final int typeId = 1;

  @override
  RecurringTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTask(
      id: fields[0] as String?,
      title: fields[1] as String,
      startDate: fields[2] as DateTime,
      timeSlot: fields[3] as String?,
      recurrenceRule: fields[4] as RecurrenceRule,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTask obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.timeSlot)
      ..writeByte(4)
      ..write(obj.recurrenceRule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
