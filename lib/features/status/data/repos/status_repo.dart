import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import 'package:whats_app/core/errors/failure.dart';
import '../../../../core/network/firebase/database_service.dart';
import '../../../../core/network/supabase/storage_service.dart';
import '../models/status_model.dart';

class StatusRepo {
  final DatabaseService firestore;
  final FirebaseFirestore store;
  final FirebaseAuth firebaseAuth;
  final StorageService storageService;

  StatusRepo({
    required this.firestore,
    required this.store,
    required this.firebaseAuth,
    required this.storageService,
  });

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


  Future<Either<Failure, void>> uploadStatus({
    required String userName,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
  }) async {
    try {
      final String uId = firebaseAuth.currentUser!.uid;
      final imageUrl = await storageService.uploadFile(
        file: statusImage,
        path: 'status/$uId/${DateTime.now().millisecondsSinceEpoch}',
      );

      final existingSnapshot = await store
          .collection('status')
          .where('uId', isEqualTo: uId)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        final existingDoc = existingSnapshot.docs.first;
        final existingModel = StatusModel.fromJson(existingDoc.data());
        final updatedPhotos = [...existingModel.photoUrl, imageUrl];

        await store.collection('status').doc(existingDoc.id).update({
          'photoUrl': updatedPhotos,
          'createAt': Timestamp.now(),
        });

        return right(null);
      }

      final statusId = const Uuid().v1();
      final newStatus = StatusModel(
        uId: uId,
        userName: userName,
        phoneNumber: phoneNumber,
        photoUrl: [imageUrl],
        createAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: const [],
      );

      await store.collection('status').doc(statusId).set(newStatus.toJson());

      _calculateWhoCanSeeInBackground(statusId: statusId);

      return right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _calculateWhoCanSeeInBackground({
    required String statusId,
  }) async {
    try {
      List<Contact> contacts = [];
      final permission = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
      if (permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited) {
        contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.phone, ContactProperty.name},
        );
      }

      final normalizedPhones = contacts
          .where((c) => c.phones.isNotEmpty)
          .map((c) => _normalizePhoneNumber(c.phones[0].number))
          .toSet()
          .toList();

      if (normalizedPhones.isEmpty) return;

      const batchSize = 10;
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> userFutures = [];

      for (int i = 0; i < normalizedPhones.length; i += batchSize) {
        final end = (i + batchSize > normalizedPhones.length)
            ? normalizedPhones.length
            : i + batchSize;
        final batch = normalizedPhones.sublist(i, end);
        userFutures.add(
          store.collection('users').where('phoneNumber', whereIn: batch).get(),
        );
      }

      final userSnapshots = await Future.wait(userFutures);

      final List<String> whoCanSee = [];
      for (final snapshot in userSnapshots) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final friendUid = data['uid'];
          if (friendUid is String) {
            whoCanSee.add(friendUid);
          }
        }
      }

      await store.collection('status').doc(statusId).update({
        'whoCanSee': whoCanSee,
      });
    } catch (e) {
     throw ServerFailure(e.toString());
    }
  }

  Future<Either<Failure, StatusModel?>> getMyStatus() async {
    try {
      final String currentUid = firebaseAuth.currentUser!.uid;
      final timeLimit = DateTime.now().subtract(const Duration(hours: 24));

      final snapshot = await store
          .collection('status')
          .where('uId', isEqualTo: currentUid)
          .where('createAt', isGreaterThan: timeLimit)
          .get();

      if (snapshot.docs.isEmpty) {
        return right(null);
      }

      return right(StatusModel.fromJson(snapshot.docs.first.data()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  Future<Either<Failure, List<StatusModel>>> getStatus() async {
    try {
      final String currentUid = firebaseAuth.currentUser!.uid;
      final timeLimit = DateTime.now().subtract(const Duration(hours: 24));

      final snapshot = await store
          .collection('status')
          .where('whoCanSee', arrayContains: currentUid)
          .where('createAt', isGreaterThan: timeLimit)
          .get();

      final statusData = <StatusModel>[];
      for (final doc in snapshot.docs) {
        final status = StatusModel.fromJson(doc.data());
        if (status.uId != currentUid) {
          statusData.add(status);
        }
      }

      return right(statusData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}