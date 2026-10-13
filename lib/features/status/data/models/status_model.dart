import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatusModel {
  final String uId;
  final String userName;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createAt;
  final String profilePic;
  final String statusId;
  final List<String> whoCanSee;

  StatusModel({
    required this.uId,
    required this.userName,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createAt,
    required this.profilePic,
    required this.statusId,
    required this.whoCanSee,
  });

  String get formattedTime {
    return DateFormat('h:mm a').format(createAt);
  }

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      uId: json['uId'] as String,
      userName: json['userName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      photoUrl: List<String>.from(json['photoUrl'] as List),
      createAt: _parseCreateAt(json['createAt']),
      profilePic: json['profilePic'] as String,
      statusId: json['statusId'] as String,
      whoCanSee: List<String>.from(json['whoCanSee'] as List),
    );
  }

  static DateTime _parseCreateAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createAt': Timestamp.fromDate(createAt),
      'profilePic': profilePic,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }
}