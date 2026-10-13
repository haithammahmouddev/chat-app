import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../../domain/entities/user_entity.dart';

@HiveType(typeId: 0)
class UserModel extends UserEntity {
  @HiveField(0)
  final String uidField;

  @HiveField(1)
  final String nameField;

  @HiveField(2)
  final String phoneNumberField;

  @HiveField(3)
  final String? imageField;

  @HiveField(4)
  final String aboutField;

  const UserModel({
    required String uid,
    required String name,
    required String phoneNumber,
    String? image,
    required String about,
    bool isOnline = false,
    List<String> groupId = const [],
  }) : uidField = uid,
       nameField = name,
       phoneNumberField = phoneNumber,
       imageField = image,
       aboutField = about,
       super(
         uid: uid,
         name: name,
         phoneNumber: phoneNumber,
         image: image,
         about: about,
         isOnline: isOnline,
         groupId: groupId,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      image: json['image'] ?? '',
      about: json['about'] ?? 'Hey there! I am using WhatsApp',
      isOnline: json['isOnline'] ?? false,
      groupId: List<String>.from(json['groupId'] ?? []),
    );
  }

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'No Exist Name',
      phoneNumber: user.phoneNumber ?? '123456789',
      image:
          user.photoURL ??
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQbksj9NS4J0zAJN5LEwzN6i0tV5dtgZmR89UzhDAK7CYCIsFvpajnCeHvl&s=10',
      about: 'Hey there! I am using WhatsApp',
      isOnline: true,
      groupId: const [],
    );
  }

  factory UserModel.fromUserEntity(UserEntity user) {
    return UserModel(
      uid: user.uid,
      name: user.name,
      phoneNumber: user.phoneNumber,
      image: user.image,
      about: user.about,
      isOnline: user.isOnline,
      groupId: user.groupId,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      image: image,
      about: about,
      isOnline: isOnline,
      groupId: groupId,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? image,
    String? about,
    bool? isOnline,
    List<String>? groupId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      image: image ?? this.image,
      about: about ?? this.about,
      isOnline: isOnline ?? this.isOnline,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'image': image,
      'about': about,
      'isOnline': isOnline,
      'groupId': groupId,
    };
  }
}
