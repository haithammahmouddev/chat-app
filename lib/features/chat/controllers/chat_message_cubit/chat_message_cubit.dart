import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/features/group/data/models/group_message_model.dart';
import '../../../group/data/repos/group_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/repos/chat_repo.dart';
import 'chat_message_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepo chatRepo;
  final GroupRepository groupRepository;

  ChatMessagesCubit({
    required this.chatRepo,
    required this.groupRepository,
  }) : super(const ChatMessagesInitial());

  StreamSubscription? _subscription;

  void getMessages({
    required String receiverUserId,
    required bool isGroupChat,
  }) {
    emit(const ChatMessagesLoading());
    _subscription?.cancel();

    if (isGroupChat) {
      _subscription = groupRepository
          .getGroupMessagesStream(groupId: receiverUserId)
          .listen((result) {
        result.fold(
              (failure) {
            emit(ChatMessagesError(failure.message));
          },
              (groupMessages) {
            emit(
              ChatMessagesLoaded(
                groupMessages.map(_fromGroupMessage).toList(),
              ),
            );
          },
        );
      });
    } else {
      _subscription = chatRepo
          .getChatMessageStreem(recieverUserId: receiverUserId)
          .listen((result) {
        result.fold(
              (failure) {
            emit(ChatMessagesError(failure.message));
          },
              (messages) {
            emit(ChatMessagesLoaded(messages));
          },
        );
      });
    }
  }

  MessageModel _fromGroupMessage(GroupMessageModel m) {
    return MessageModel(
      senderId: m.senderId,
      recieverId: '',
      text: m.text,
      type: m.type,
      timeSent: m.timeSent,
      messageId: m.messageId,
      isSeen: true,
      repliedMessage: '',
      repliedTo: m.senderName,
      repliedTypeMessage: MessageEnum.text,
    );
  }

  void setChatMessageSeen({
    required String recieverUserId,
    required String messageId,
  }) async {
    await chatRepo.setChatMessageSeen(
      recieverUserId: recieverUserId,
      messageId: messageId,
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}