import 'package:hive_ce_flutter/adapters.dart';
import 'package:whats_app/features/auth/data/models/user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      image: fields[3] as String?,
      about: fields[4] as String,
      isOnline: fields[5] as bool? ?? false,
      groupId: (fields[6] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.uid)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.phoneNumber)
      ..writeByte(3)..write(obj.image)
      ..writeByte(4)..write(obj.about)
      ..writeByte(5)..write(obj.isOnline)
      ..writeByte(6)..write(obj.groupId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
