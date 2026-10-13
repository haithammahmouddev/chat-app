import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/enums/message_enum.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/supabase/storage_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/droup_model.dart';
import '../models/group_message_model.dart';

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final StorageService storageService;

  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.storageService,
  });

  Future<void> createGroup({
    required String name,
    required File profilePic,
    required List<Contact> selectedContact,
  }) async {
    List<String> uids = [];

    for (int i = 0; i < selectedContact.length; i++) {
      if (selectedContact[i].phones.isEmpty) continue;

      final normalizedPhone =
      _normalizePhoneNumber(selectedContact[i].phones[0].number);

      var userCollection = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: normalizedPhone)
          .get();

      if (userCollection.docs.isNotEmpty) {
        uids.add(userCollection.docs[0].data()['uid']);
      }
    }

    final groupId = const Uuid().v1();

    final profileUrl = await storageService.uploadFile(
      file: profilePic,
      path: 'group/$groupId',
    );

    final GroupModel group = GroupModel(
      senderId: auth.currentUser!.uid,
      name: name,
      groupId: groupId,
      lastMessage: '',
      groupPic: profileUrl,
      membersUid: [auth.currentUser!.uid, ...uids],
      timeSent: DateTime.now(),
    );

    await firestore.collection('groups').doc(groupId).set(group.toMap());
  }

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    final status = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone, ContactProperty.name},
      );
    }

    final Map<String, Contact> phoneToContact = {};

    for (var contact in contacts) {
      if (contact.phones.isNotEmpty) {
        final normalizedPhone = _normalizePhoneNumber(contact.phones[0].number);
        phoneToContact[normalizedPhone] = contact;
      }
    }

    final allPhones = phoneToContact.keys.toList();
    final List<Contact> registeredContacts = [];

    if (allPhones.isNotEmpty) {
      const batchSize = 10;
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> userFutures = [];

      for (int i = 0; i < allPhones.length; i += batchSize) {
        final end = (i + batchSize > allPhones.length)
            ? allPhones.length
            : i + batchSize;
        final batch = allPhones.sublist(i, end);

        userFutures.add(
          firestore.collection('users').where('phoneNumber', whereIn: batch).get(),
        );
      }

      final userSnapshots = await Future.wait(userFutures);
      final String? currentUid = auth.currentUser?.uid;

      for (final snapshot in userSnapshots) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final registeredPhone = data['phoneNumber'] as String?;

          final docUid = data['uid'] as String? ?? doc.id;
          final isMe = currentUid != null && docUid == currentUid;
          if (isMe) continue;

          if (registeredPhone != null &&
              phoneToContact.containsKey(registeredPhone)) {
            registeredContacts.add(phoneToContact[registeredPhone]!);
          }
        }
      }
    }

    return registeredContacts;
  }

  Future<void> sendGroupTextMessage({
    required String groupId,
    required String text,
    required UserModel senderUser,
  }) async {
    final messageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final message = GroupMessageModel(
      senderId: senderUser.uid,
      senderName: senderUser.name,
      text: text,
      timeSent: timeSent,
      messageId: messageId,
      type: MessageEnum.text,
    );

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore.collection('groups').doc(groupId).update({
      'lastMessage': text,
      'timeSent': timeSent.millisecondsSinceEpoch,
    });
  }

  Future<void> sendGroupFileMessage({
    required String groupId,
    required File file,
    required UserModel senderUser,
    required MessageEnum messageType,
  }) async {
    final messageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final String fileUrl = await storageService.uploadFile(
      file: file,
      path: 'group/${messageType.type}/$groupId/$messageId',
    );

    final message = GroupMessageModel(
      senderId: senderUser.uid,
      senderName: senderUser.name,
      text: fileUrl,
      timeSent: timeSent,
      messageId: messageId,
      type: messageType,
    );

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    String contactMsg;
    switch (messageType) {
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
      case MessageEnum.text:
        contactMsg = fileUrl;
        break;
    }

    await firestore.collection('groups').doc(groupId).update({
      'lastMessage': contactMsg,
      'timeSent': timeSent.millisecondsSinceEpoch,
    });
  }

  Future<void> sendGroupGIFMessage({
    required String groupId,
    required String gifUrl,
    required UserModel senderUser,
  }) async {
    final messageId = const Uuid().v1();
    final timeSent = DateTime.now();

    final message = GroupMessageModel(
      senderId: senderUser.uid,
      senderName: senderUser.name,
      text: gifUrl,
      timeSent: timeSent,
      messageId: messageId,
      type: MessageEnum.gif,
    );

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore.collection('groups').doc(groupId).update({
      'lastMessage': 'GIF',
      'timeSent': timeSent.millisecondsSinceEpoch,
    });
  }

  Stream<Either<Failure, List<GroupMessageModel>>> getGroupMessagesStream({
    required String groupId,
  }) async* {
    try {
      final data = firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .orderBy('timeSent', descending: false);

      await for (var result in data.snapshots()) {
        yield right<Failure, List<GroupMessageModel>>(
          result.docs
              .map((doc) => GroupMessageModel.fromMap(doc.data()))
              .toList(),
        );
      }
    } catch (e) {
      yield left(ServerFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<GroupModel>>> getUserGroupsStream() async* {
    try {
      final currentUid = auth.currentUser!.uid;
      final data = firestore
          .collection('groups')
          .where('membersUid', arrayContains: currentUid);

      await for (var result in data.snapshots()) {
        yield right<Failure, List<GroupModel>>(
          result.docs.map((doc) => GroupModel.fromMap(doc.data())).toList(),
        );
      }
    } catch (e) {
      yield left(ServerFailure(e.toString()));
    }
  }

  String _normalizePhoneNumber(String rawNumber) {
    String number = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (number.startsWith('+20')) {
      return number;
    } else if (number.startsWith('20')) {
      return '+$number';
    } else if (number.startsWith('0')) {
      return '+20${number.substring(1)}';
    } else {
      return '+20$number';
    }
  }
}