import 'package:whats_app/core/enums/message_enum.dart';

class MessageReply  {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply({
    required this.message,
    required this.isMe,
    required this.messageEnum
  });
}

