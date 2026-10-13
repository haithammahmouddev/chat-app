import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/core/message_reply_cubit/message_reply_cubit.dart';
import 'package:whats_app/core/message_reply_cubit/message_reply_state.dart';
import '../../../../../colors.dart';
import '../../../../../core/providers/message_reply_provider.dart';
import '../../controllers/send_message_cubit/send_message_cubit.dart';
import '../../controllers/send_message_cubit/send_message_state.dart';
import 'message_reply_review.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  final String recieverUserId;
  final bool isGroupChat;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late final TextEditingController messageController;
  final FocusNode focusNode = FocusNode();
  bool isShowSendButton = false;
  bool isShowEmojiContainer = false;
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    focusNode.dispose();
    _soundRecorder?.closeRecorder();
    isRecorderInit = false;
  }

  Future<void> openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic Permission Not allowed!');
    }
    await _soundRecorder?.openRecorder();
    isRecorderInit = true;
  }

  Future<void> sendFileMessage({
    required MessageEnum messageEnum,
    required File file,
  }) async {
    await context.read<SendMessageCubit>().sendFileMessage(
      file: file,
      receiverUserId: widget.recieverUserId,
      messageEnum: messageEnum,
      isGroupChat: widget.isGroupChat,
    );
  }

  Future<void> selectImage(BuildContext context) async {
    final File? image = await _showMediaSourceDialog(context, mediaType: MessageEnum.image);
    if (image != null) {
      await sendFileMessage(messageEnum: MessageEnum.image, file: image);
    }
  }

  Future<void> selectVideo(BuildContext context) async {
    final File? video = await _showMediaSourceDialog(context, mediaType: MessageEnum.video);
    if (video != null) {
      await sendFileMessage(messageEnum: MessageEnum.video, file: video);
    }
  }

  Future<void> _sendMessage({required MessageReply? messageReply}) async {
    if (isShowSendButton) {
      final text = messageController.text.trim();
      if (text.isEmpty) return;

      await context.read<SendMessageCubit>().sendTextMessage(
        text: text,
        receiverUserId: widget.recieverUserId,
        messageReply: messageReply,
        isGroupChat: widget.isGroupChat,
      );

      messageController.clear();

      if (messageReply != null) {
        context.read<MessageReplyCubit>().cancelReply();
      }

      setState(() {
        isShowSendButton = false;
        isShowEmojiContainer = false;
      });
    } else {
      if (!isRecorderInit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone is still initializing, try again in a moment.')),
        );
        return;
      }

      try {
        var temDir = await getTemporaryDirectory();
        var path = '${temDir.path}/flutter_sound.aac';

        if (isRecording) {
          await _soundRecorder?.stopRecorder();
          await sendFileMessage(messageEnum: MessageEnum.audio, file: File(path));
        } else {
          await _soundRecorder?.startRecorder(
            toFile: path,
          );
        }

        setState(() {
          isRecording = !isRecording;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording failed: ${e.toString()}')),
        );
        setState(() {
          isRecording = false;
        });
      }
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeybord() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeybord();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    setState(() {
      messageController.text = messageController.text + emoji.emoji;
      isShowSendButton = messageController.text.trim().isNotEmpty;
    });
  }

  void _onBackspacePressed() {
    final text = messageController.text;
    if (text.isEmpty) return;

    setState(() {
      messageController.text = text.substring(0, text.length - 1);
      isShowSendButton = messageController.text.trim().isNotEmpty;
    });
  }

  Future<GiphyGif?> pickGIF(BuildContext context) async {
    try {
      final reponse = await Giphy.getGif(
        context: context,
        apiKey: 'aW7l8EF0e1UZVktHKDNoSRiRU21Vpzmu',
      );
      return reponse;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }

  Future<void> selectGIF(BuildContext context) async {
    final gif = await pickGIF(context);
    if (gif != null) {
      context.read<SendMessageCubit>().sendGIFMessage(
        gifUrl: gif.url,
        recieverUserId: widget.recieverUserId,
        isGroupChat: widget.isGroupChat,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageReplyCubit, MessageReplyState>(
      builder: (context, replyState) {
        final messageReply =
        replyState is MessageReplyActive ? replyState.messageReply : null;
        final isShowMessageReply = messageReply != null;

        return PopScope(
          canPop: !isShowEmojiContainer,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (isShowEmojiContainer) {
              hideEmojiContainer();
            }
          },
          child: BlocListener<SendMessageCubit, SendMessageState>(
            listener: (context, state) {
              if (state is SendMessageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  isShowMessageReply ? MessageReplyReview() : const SizedBox(),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          focusNode: focusNode,
                          onChanged: (value) {
                            setState(() {
                              isShowSendButton = value.trim().isNotEmpty;
                            });
                          },
                          onTap: () {
                            if (isShowEmojiContainer) {
                              hideEmojiContainer();
                            }
                          },
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: mobileChatBoxColor,
                            hintText: 'Type a message!',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),

                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 4),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: Icon(
                                    isShowEmojiContainer ? Icons.keyboard : Icons.emoji_emotions_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: toggleEmojiKeyboardContainer,
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () async {
                                    await selectGIF(context);
                                  },
                                  icon: const Icon(
                                    Icons.gif_box_outlined,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),

                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                                  onPressed: () async {
                                    await selectVideo(context);
                                  },
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                                  onPressed: () async {
                                    await selectImage(context);
                                  },
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        backgroundColor: tabColor,
                        radius: 23,
                        child: BlocBuilder<SendMessageCubit, SendMessageState>(
                          builder: (context, state) {
                            if (state is SendMessageLoading) {
                              return const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              );
                            }

                            return IconButton(
                              onPressed: () {
                                _sendMessage(messageReply: messageReply);
                              },
                              icon: Icon(
                                isShowSendButton ? Icons.send : isRecording ? Icons.close : Icons.mic,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Offstage(
                    offstage: !isShowEmojiContainer,
                    child: SizedBox(
                      height: 280,
                      child: EmojiPicker(
                        onEmojiSelected: _onEmojiSelected,
                        onBackspacePressed: _onBackspacePressed,
                        config: Config(
                          height: 310,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 8,
                            emojiSizeMax: 28,
                            backgroundColor: mobileChatBoxColor,
                            recentsLimit: 28,
                            loadingIndicator: const SizedBox.shrink(),
                          ),
                          categoryViewConfig: CategoryViewConfig(
                            indicatorColor: tabColor,
                            iconColorSelected: tabColor,
                            backgroundColor: mobileChatBoxColor,
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(
                            backgroundColor: mobileChatBoxColor,
                            buttonColor: tabColor,
                          ),
                          searchViewConfig: SearchViewConfig(
                            backgroundColor: mobileChatBoxColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<File?> _showMediaSourceDialog(
      BuildContext context, {
        required MessageEnum mediaType,
      }) {
    final cubit = context.read<SendMessageCubit>();
    final isVideo = mediaType == MessageEnum.video;

    return showDialog<File?>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(isVideo ? 'Choose Video Source' : 'Choose Image Source'),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                final file = isVideo
                    ? await cubit.pickVedio(ImageSource.camera)
                    : await cubit.pickImage(ImageSource.camera);

                Navigator.pop(dialogContext, file);
              },
              child: Row(
                children: [
                  Icon(isVideo ? Icons.videocam : Icons.camera_alt),
                  const SizedBox(width: 10),
                  Text(isVideo ? 'Record Video' : 'Camera'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final file = isVideo
                    ? await cubit.pickVedio(ImageSource.gallery)
                    : await cubit.pickImage(ImageSource.gallery);

                Navigator.pop(dialogContext, file);
              },
              child: Row(
                children: [
                  Icon(isVideo ? Icons.video_library : Icons.photo_library),
                  const SizedBox(width: 10),
                  Text(isVideo ? 'Choose Video' : 'Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}