import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import '../../../../core/providers/message_reply_provider.dart';
import '../../../../core/services/save_user_by_hive.dart';
import '../../../group/data/repos/group_repository.dart';
import '../../data/repos/chat_repo.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final ChatRepo chatRepo;
  final GroupRepository groupRepository;

  SendMessageCubit({
    required this.chatRepo,
    required this.groupRepository,
  }) : super(const SendMessageInitial());

  Future<void> sendTextMessage({
    required String text,
    required String receiverUserId,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    final message = text.trim();

    if (message.isEmpty) {
      emit(const SendMessageError('Message cannot be empty'));
      return;
    }

    emit(const SendMessageLoading());

    try {
      final currentUser = UserRepository().getUser();
      if (currentUser == null) {
        emit(const SendMessageError('User not found'));
        return;
      }

      if (isGroupChat) {
        await groupRepository.sendGroupTextMessage(
          groupId: receiverUserId,
          text: message,
          senderUser: currentUser,
        );
      } else {
        await chatRepo.sendTextMessage(
          text: message,
          recieverUserId: receiverUserId,
          senderUser: currentUser,
          messageReply: messageReply,
        );
      }

      emit(const SendMessageSuccess());
    } catch (e) {
      emit(SendMessageError(e.toString()));
    }
  }

  Future<void> sendFileMessage({
    required File file,
    required String receiverUserId,
    required MessageEnum messageEnum,
    required bool isGroupChat,
  }) async {
    final message = file;

    if (message.path.isEmpty) {
      emit(const SendMessageError('Message cannot be empty'));
      return;
    }

    emit(const SendMessageLoading());

    try {
      final currentUser = UserRepository().getUser();
      if (currentUser == null) {
        emit(const SendMessageError('User not found'));
        return;
      }

      if (isGroupChat) {
        await groupRepository.sendGroupFileMessage(
          groupId: receiverUserId,
          file: file,
          senderUser: currentUser,
          messageType: messageEnum,
        );
      } else {
        await chatRepo.sendFileMessage(
          recieverUserId: receiverUserId,
          file: file,
          senderUserData: currentUser,
          message: messageEnum,
        );
      }

      emit(const SendMessageSuccess());
    } catch (e) {
      emit(SendMessageError(e.toString()));
    }
  }

  Future<File?> pickVedio(ImageSource source) async {
    try {
      final pickVideo = await ImagePicker().pickVideo(source: source);
      if (pickVideo == null) return null;
      return File(pickVideo.path);
    } catch (e) {
      emit(const SendMessageError('image not found'));
      return null;
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      emit(const SendMessageError('image not found'));
      return null;
    }
  }

  Future<void> sendGIFMessage({
    required String gifUrl,
    required String recieverUserId,
    required bool isGroupChat,
  }) async {
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    final currentUser = UserRepository().getUser();
    if (currentUser == null) return;

    if (isGroupChat) {
      await groupRepository.sendGroupGIFMessage(
        groupId: recieverUserId,
        gifUrl: newgifUrl,
        senderUser: currentUser,
      );
    } else {
      await chatRepo.sendGIFMessage(
        gifUrl: newgifUrl,
        recieverUserId: recieverUserId,
        senderUser: currentUser,
      );
    }
  }
}