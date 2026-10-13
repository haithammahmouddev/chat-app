import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whats_app/core/message_reply_cubit/message_reply_cubit.dart';
import 'package:whats_app/features/auth/presentation/controllers/phone_auth_controller/phone_auth_bloc.dart';
import 'package:whats_app/features/call/screens/call_pickup_screen.dart';
import 'package:whats_app/features/call/screens/call_screen.dart';
import '../../../../colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../call/controller/call_cubit.dart';
import '../controllers/chat_message_cubit/chat_message_cubit.dart';
import '../controllers/send_message_cubit/send_message_cubit.dart';
import 'widgets/bottom_chat_field.dart';
import 'widgets/chat_list.dart';

class ChatRoomScreen extends StatelessWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;

  const ChatRoomScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  void makeCall(BuildContext context) {
    context.read<CallCubit>().makeCall(
      receiverUid: uid,
      receiverName: name,
      receiverProfilePic: profilePic,
      isGroupChat: isGroupChat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatMessagesCubit>(
          create: (_) => sl<ChatMessagesCubit>()
            ..getMessages(
              receiverUserId: uid,
              isGroupChat: isGroupChat,
            ),
        ),
        BlocProvider<SendMessageCubit>(
          create: (_) => sl<SendMessageCubit>(),
        ),
        if (!isGroupChat)
          BlocProvider<PhoneAuthBloc>(
            create: (_) => sl<PhoneAuthBloc>()..fetchUserData(uId: uid),
          ),
        BlocProvider<MessageReplyCubit>(
          create: (_) => sl<MessageReplyCubit>(),
        ),
        BlocProvider<CallCubit>(
          create: (_) => sl<CallCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<CallCubit, CallState>(
            listener: (context, state) {
              if (state is CallMakeSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                      channelId: state.call.callId,
                      call: state.call,
                      isGroupChat: state.isGroupChat,
                    ),
                  ),
                );
              } else if (state is CallMakeFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: CallPickupScreen(
              scaffold: Scaffold(
                appBar: AppBar(
                  backgroundColor: appBarColor,
                  centerTitle: false,
                  title: isGroupChat
                      ? Text(name)
                      : BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                    builder: (context, state) {
                      if (state is UserDataLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.user.name),
                            Text(
                              state.user.isOnline ? 'online' : 'offline',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => makeCall(context),
                      icon: const Icon(Icons.video_call),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ChatList(
                        recieverUserId: uid,
                        isGroupChat: isGroupChat,
                      ),
                    ),
                    BottomChatField(
                      recieverUserId: uid,
                      isGroupChat: isGroupChat,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}