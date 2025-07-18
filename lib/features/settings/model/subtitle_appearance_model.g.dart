// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_appearance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubtitleAppearanceModelAdapter
    extends TypeAdapter<SubtitleAppearanceModel> {
  @override
  final int typeId = 10;

  @override
  SubtitleAppearanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubtitleAppearanceModel(
      fontSize: fields[0] == null ? 16.0 : fields[0] as double,
      textColor: fields[1] == null ? 4294967295 : fields[1] as int,
      backgroundOpacity: fields[2] == null ? 0.5 : fields[2] as double,
      hasShadow: fields[3] == null ? true : fields[3] as bool,
      shadowOpacity: fields[4] == null ? 0.5 : fields[4] as double,
      shadowBlur: fields[5] == null ? 2.0 : fields[5] as double,
      fontFamily: fields[6] as String?,
      position: fields[7] == null ? 1 : fields[7] as int,
      boldText: fields[8] == null ? true : fields[8] as bool,
      forceUppercase: fields[9] == null ? false : fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubtitleAppearanceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.fontSize)
      ..writeByte(1)
      ..write(obj.textColor)
      ..writeByte(2)
      ..write(obj.backgroundOpacity)
      ..writeByte(3)
      ..write(obj.hasShadow)
      ..writeByte(4)
      ..write(obj.shadowOpacity)
      ..writeByte(5)
      ..write(obj.shadowBlur)
      ..writeByte(6)
      ..write(obj.fontFamily)
      ..writeByte(7)
      ..write(obj.position)
      ..writeByte(8)
      ..write(obj.boldText)
      ..writeByte(9)
      ..write(obj.forceUppercase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtitleAppearanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
