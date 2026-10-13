import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/core/message_reply_cubit/message_reply_cubit.dart';
import 'package:whats_app/core/providers/message_reply_provider.dart';
import '../../../../../core/message_reply_cubit/message_reply_state.dart';
import 'display_message.dart';

class MessageReplyReview extends StatelessWidget {
  const MessageReplyReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BlocBuilder<MessageReplyCubit, MessageReplyState>(
                  builder: (context, state) {
                    if (state is MessageReplyActive) {
                      final MessageReply messageReply = state.messageReply;
                      if (messageReply.messageEnum == MessageEnum.text) {
                        return DisplayMessage(
                          message: messageReply.message,
                          type: messageReply.messageEnum,
                        );
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: DisplayMessage(
                              message: messageReply.message,
                              type: messageReply.messageEnum,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<MessageReplyCubit>().cancelReply();
                },
                icon: const Icon(Icons.close),
                iconSize: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}