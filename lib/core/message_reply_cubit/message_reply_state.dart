import 'package:flutter/foundation.dart';

import '../providers/message_reply_provider.dart';

@immutable
abstract class MessageReplyState {}

class MessageReplyInitial extends MessageReplyState {}

class MessageReplyActive extends MessageReplyState {
  final MessageReply messageReply;

  MessageReplyActive(this.messageReply);
}
