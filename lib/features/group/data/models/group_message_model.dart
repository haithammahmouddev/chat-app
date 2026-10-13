import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/message_enum.dart';

class GroupMessageModel {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timeSent;
  final String messageId;
  final MessageEnum type;

  GroupMessageModel({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timeSent,
    required this.messageId,
    this.type = MessageEnum.text,
  });

  String get formattedTime => DateFormat('h:mm a').format(timeSent);

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timeSent': Timestamp.fromDate(timeSent),
      'messageId': messageId,
      'type': type.type,
    };
  }

  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      timeSent: map['timeSent'] is Timestamp
          ? (map['timeSent'] as Timestamp).toDate()
          : DateTime.now(),
      messageId: map['messageId'] ?? '',
      type: (map['type'] as String? ?? 'text').toEnum(),
    );
  }
}