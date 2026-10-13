import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatContactModel {
  final String name;
  final String? image;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;

  ChatContactModel({
    required this.name,
    this.image,
    required this.contactId,
    required this.timeSent,
    required this.lastMessage,
  });

  String get formattedTime => DateFormat('h:mm a').format(timeSent);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'contactId': contactId,
      'timeSent': Timestamp.fromDate(timeSent),
      'lastMessage': lastMessage,
    };
  }

  factory ChatContactModel.fromMap(Map<String, dynamic> map) {
    return ChatContactModel(
      name: map['name'] ?? '',
      image: map['image'],
      contactId: map['contactId'] ?? '',
      timeSent: _parseTimeSent(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
    );
  }

  static DateTime _parseTimeSent(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}