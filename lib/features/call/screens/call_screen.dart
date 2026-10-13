import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/config/agora_config.dart';
import '../controller/call_cubit.dart';
import '../data/models/call_model.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final CallModel call;
  final bool isGroupChat;

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RtcEngine? agoraEngine;
  bool isJoined = false;
  int? remoteUid;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine!.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    agoraEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          setState(() {
            remoteUid = uid;
          });
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          setState(() {
            remoteUid = null;
          });
        },
      ),
    );

    await agoraEngine!.enableVideo();
    await agoraEngine!.startPreview();

    await agoraEngine!.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  void dispose() {
    agoraEngine?.leaveChannel();
    agoraEngine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: agoraEngine == null || !isJoined
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Stack(
          children: [
            Center(
              child: remoteUid != null
                  ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: agoraEngine!,
                  canvas: VideoCanvas(uid: remoteUid),
                  connection: RtcConnection(channelId: widget.channelId),
                ),
              )
                  : const Text(
                "جاري انتظار الطرف الآخر...",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),

            Positioned(
              top: 20,
              right: 20,
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraEngine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'micBtn',
                    backgroundColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                      agoraEngine!.muteLocalAudioStream(isMuted);
                    },
                    child: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  FloatingActionButton(
                    heroTag: 'hangupBtn',
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      await agoraEngine!.leaveChannel();
                      if (!context.mounted) return;
                      context.read<CallCubit>().endCall(
                        callerId: widget.call.callerId,
                        receiverId: widget.call.receiverId,
                      );
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.call_end, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}