import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/core/message_reply_cubit/message_reply_cubit.dart';
import '../../../../core/providers/message_reply_provider.dart';
import '../../controllers/chat_message_cubit/chat_message_cubit.dart';
import '../../controllers/chat_message_cubit/chat_message_state.dart';
import '../../data/models/message_model.dart';
import 'my_message_card.dart';
import 'sender_message_card.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  final String recieverUserId;
  final bool isGroupChat;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late final ScrollController _scrollController;
  final Set<String> _seenRequestsSent = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onMessageSwipe({
    required BuildContext context,
    required String message,
    required bool isMe,
    required MessageEnum messageEnum,
  }) {
    context.read<MessageReplyCubit>().setMessageReply(
      MessageReply(message: message, isMe: isMe, messageEnum: messageEnum),
    );
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _markAsSeenIfNeeded(MessageModel message) {
    if (widget.isGroupChat) return;

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isIncomingUnseen =
        !message.isSeen && message.recieverId == currentUid;

    if (!isIncomingUnseen) return;
    if (_seenRequestsSent.contains(message.messageId)) return;

    _seenRequestsSent.add(message.messageId);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatMessagesCubit>().setChatMessageSeen(
        recieverUserId: widget.recieverUserId,
        messageId: message.messageId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
      listener: (context, state) {
        if (state is ChatMessagesLoaded) _scrollToBottom();
      },
      builder: (context, state) {
        if (state is ChatMessagesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatMessagesError) {
          return Center(child: Text(state.message));
        }

        if (state is ChatMessagesLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return const Center(child: Text("ابدأ المحادثة"));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final MessageModel message = messages[index];
              final isMe =
                  message.senderId == FirebaseAuth.instance.currentUser!.uid;

              _markAsSeenIfNeeded(message);

              if (isMe) {
                return MyMessageCard(
                  message: message.text,
                  date: message.formattedTime,
                  type: message.type,
                  onLeftSwipe: () => onMessageSwipe(
                    context: context,
                    message: message.text,
                    isMe: true,
                    messageEnum: message.type,
                  ),
                  repliedText: message.repliedMessage,
                  userName: message.repliedTo,
                  repliedMessageType: message.repliedTypeMessage,
                  isSeen: message.isSeen,
                );
              }

              return SenderMessageCard(
                message: message.text,
                date: message.formattedTime,
                type: message.type,
                onLeftSwipe: () => onMessageSwipe(
                  context: context,
                  message: message.text,
                  isMe: false,
                  messageEnum: message.type,
                ),
                repliedText: message.repliedMessage,
                userName: message.repliedTo,
                repliedMessageType: message.repliedTypeMessage,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}