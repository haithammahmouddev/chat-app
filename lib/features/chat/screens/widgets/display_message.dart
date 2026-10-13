import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/features/chat/screens/widgets/video_player_item.dart';

class DisplayMessage extends StatelessWidget {
    DisplayMessage({super.key, required this.message, required this.type});
  final String message;
  final MessageEnum type;
  bool isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return switch(type){
       MessageEnum.text => Text(
        message,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
       MessageEnum.image => CachedNetworkImage(
         maxHeightDiskCache: 400,
         maxWidthDiskCache: 400,
         memCacheWidth: 50,
         imageUrl: message,
       ),
       MessageEnum.audio => StatefulBuilder(
         builder:(context, setState){
           return  IconButton(
             constraints: BoxConstraints(
               minWidth: 100,
             ),
             onPressed: () async{
               if(isPlaying){
                 await audioPlayer.pause();
                 setState((){
                   isPlaying = false;
                 });
               }else{
                 await audioPlayer.play(UrlSource(message));
                 setState((){
                   isPlaying = true;
                 });
               }
             }, icon:  Icon(isPlaying ? CupertinoIcons.stop_circle : CupertinoIcons.play_circle),);
         }
       ),
       MessageEnum.video => VideoPlayerItem(videoUrl: message,),
       MessageEnum.gif =>  CachedNetworkImage(imageUrl: message,),
    };
  }
}
