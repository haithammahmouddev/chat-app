import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app/core/enums/message_enum.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';
import 'package:whats_app/core/providers/message_reply_provider.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/supabase/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/chat_contact_model.dart';
import '../models/message_model.dart';

class ChatRepo {
  final DatabaseService firestore;
  final FirebaseFirestore store;
  final FirebaseAuth firebaseAuth;
  final StorageService storageService;
  ChatRepo({required this.firestore, required this.firebaseAuth, required this.store, required this.storageService});


  Future<void> sendTextMessage({
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
}) async{
    try{
      final timeSent = DateTime.now();
       final userDataMap = await firestore.getData(path: 'users',
          docId: recieverUserId);

      final recieverUserData = UserModel.fromJson(userDataMap!);

      final String messageId = const Uuid().v1();

       await  _saveDataToContactsSubCollection(
           senderUserData: senderUser,
           recieverUserData: recieverUserData,
           text: text,
           timeSent: timeSent,
           recieveUserId: recieverUserId);

     await _saveMessageToMessageSubCollection(
          recieverUserId: recieverUserId,
          text: text,
          timeSent: timeSent,
          messageId: messageId,
          userName: senderUser.name,
          recieverUserName: recieverUserData.name,
          messageType: MessageEnum.text,
         messageReply: messageReply,
         senderUserName: senderUser.name,
         repliedMessageType: messageReply == null ?
         MessageEnum.text : messageReply.messageEnum);

    }catch(e){
  throw Exception(e.toString());
    }
}

  Future<void> _saveDataToContactsSubCollection({
    required UserModel senderUserData,
    required UserModel recieverUserData,
    required String text,
    required DateTime timeSent,
    required String recieveUserId,
  }) async {
    final myUid = firebaseAuth.currentUser!.uid;

     final ChatContactModel senderChatContact = ChatContactModel(
      name: recieverUserData.name,
      image: recieverUserData.image,
      contactId: recieverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );

    await store
        .collection('users')
        .doc(myUid)
        .collection('chats')
        .doc(recieveUserId)
        .set(senderChatContact.toMap());

    final ChatContactModel recieverChatContact = ChatContactModel(
      name: senderUserData.name,
      image: senderUserData.image,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );

    await store
        .collection('users')
        .doc(recieveUserId)
        .collection('chats')
        .doc(myUid)
        .set(recieverChatContact.toMap());
  }


  Future<void> _saveMessageToMessageSubCollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String userName,
    required String recieverUserName,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUserName,
    required MessageEnum repliedMessageType,
  }) async {
   final MessageModel messageModel = MessageModel(senderId: firebaseAuth.currentUser!.uid,
       recieverId: recieverUserId,
       text: text,
       type: messageType,
       timeSent: timeSent,
       messageId: messageId,
       isSeen: false,
       repliedMessage:messageReply == null ? '' : messageReply.message,
       repliedTo:messageReply == null ? '' : messageReply.isMe ? 'you' : recieverUserName,
     repliedTypeMessage: messageReply != null ? messageReply.messageEnum : MessageEnum.text,
    );

   await store.collection('users').
   doc(firebaseAuth.currentUser!.uid).
   collection('chats').
   doc(recieverUserId).collection('message').doc(messageId).set(messageModel.toMap());

   await store.collection('users').
   doc(recieverUserId).
   collection('chats').
   doc(firebaseAuth.currentUser!.uid).collection('message').doc(messageId).set(messageModel.toMap());
  }


  Stream<Either<Failure, List<ChatContactModel>>> getChatContactsStream() async*{
    try{
      final data =  store.collection('users').
      doc(firebaseAuth.currentUser!.uid).collection('chats');
      await for (var result in data.snapshots()){
        yield  right(
            result.docs
            .map((doc) => doc.data())
            .map((e)=>ChatContactModel.fromMap(e)).toList());
      }
    }catch(e){
      yield left(ServerFailure(e.toString()));
    }
  }


  Stream<Either<Failure, List<MessageModel>>> getChatMessageStreem({
    required String recieverUserId,
})async*{
    try{
      final data =   store
          .collection('users')
          .doc(firebaseAuth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('message')
          .orderBy('timeSent', descending: false);

      await for(var result in data.snapshots()){
        yield right(
            result.docs
                .map((doc) => doc.data())
                .map((e)=>MessageModel.fromMap(e)).toList());
      }
    }catch(e){
      yield left(ServerFailure(e.toString()));
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    try {
      await store
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'isOnline': isOnline});
    } catch (e) {

    }
  }

  Future<Either<Failure, void>> sendFileMessage({
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageEnum message,
    MessageReply? messageReply
  }) async {
    try {
      final timeSent = DateTime.now();
      final messageId = const Uuid().v1();

       final String fileUrl = await storageService.uploadFile(
        file: file,
        path: 'chat/${message.type}/${senderUserData.uid}$recieverUserId$messageId',
      );

      var userDataMap = await firestore.getData(path: 'users', docId: recieverUserId);
      final recieverUserData = UserModel.fromJson(userDataMap!);

      String contactMsg;
      switch (message) {
        case MessageEnum.text:
          contactMsg = 'text';
          break;
        case MessageEnum.image:
          contactMsg = '📸 صورة';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 مقطع صوتي';
          break;
        case MessageEnum.video:
          contactMsg = '🎥 فيديو';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
      }

       await _saveDataToContactsSubCollection(
        senderUserData: senderUserData,
        recieverUserData: recieverUserData,
        text: contactMsg,
        timeSent: timeSent,
        recieveUserId: recieverUserId,
      );
      await _saveMessageToMessageSubCollection(
        recieverUserId: recieverUserId,
        text: fileUrl,
        timeSent: timeSent,
        messageId: messageId,
        userName: senderUserData.name,
        recieverUserName: recieverUserData.name,
        messageType: message,
        messageReply: messageReply,
        senderUserName: senderUserData.name,
        repliedMessageType:  messageReply == null ?
        MessageEnum.text : messageReply!.messageEnum);
      return right(null);
    } catch (e) {
       return left(ServerFailure(e.toString()));
    }
  }

  Future<void> sendGIFMessage({
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    MessageReply? messageReply
  }) async{
    try{
      final timeSent = DateTime.now();
      final userDataMap = await firestore.getData(path: 'users',
          docId: recieverUserId);

      final recieverUserData = UserModel.fromJson(userDataMap!);

      final String messageId = const Uuid().v1();

      await  _saveDataToContactsSubCollection(
          senderUserData: senderUser,
          recieverUserData: recieverUserData,
          text: 'GIF',
          timeSent: timeSent,
          recieveUserId: recieverUserId);

      await _saveMessageToMessageSubCollection(
          recieverUserId: recieverUserId,
          text: gifUrl,
          timeSent: timeSent,
          messageId: messageId,
          userName: senderUser.name,
          recieverUserName: recieverUserData.name,
          messageType: MessageEnum.gif,
          messageReply: messageReply,
          senderUserName: senderUser.name,
          repliedMessageType:  messageReply == null ?
          MessageEnum.text : messageReply.messageEnum);

    }catch(e){
      throw Exception(e.toString());
    }
  }


  Future<Either<Failure, void>> setChatMessageSeen({
    required String recieverUserId,
    required String messageId,
}) async{
    try{
      await store.collection('users').
      doc(firebaseAuth.currentUser!.uid).
      collection('chats').
      doc(recieverUserId).collection('message').doc(messageId)
          .update({
         'isSeen': true,
      });

      await store.collection('users').
      doc(recieverUserId).
      collection('chats').
      doc(firebaseAuth.currentUser!.uid).collection('message')
          .doc(messageId).update({
        'isSeen': true,
        });
       return right(null);
    }catch(e){
      return left(ServerFailure(e.toString()));
    }
  }


}

