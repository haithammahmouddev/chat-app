import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/message_reply_provider.dart';
import 'message_reply_state.dart';

class MessageReplyCubit extends Cubit<MessageReplyState> {
  MessageReplyCubit() : super(MessageReplyInitial());

  void setMessageReply(MessageReply reply) {
    emit(MessageReplyActive(reply));
  }

  void cancelReply() {
    emit(MessageReplyInitial());
  }


  MessageReply? get messageReply {
    final s = state;
    return s is MessageReplyActive ? s.messageReply : null;
  }
}