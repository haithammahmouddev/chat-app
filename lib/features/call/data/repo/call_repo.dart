
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../group/data/models/droup_model.dart';
import '../models/call_model.dart';


class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });


  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();


  Future<void> makeCall({
    required CallModel senderCallData,
    required CallModel receiverCallData,
  }) async {
    await firestore
        .collection('call')
        .doc(senderCallData.callerId)
        .set(senderCallData.toMap());

    await firestore
        .collection('call')
        .doc(senderCallData.receiverId)
        .set(receiverCallData.toMap());
  }


  Future<void> makeGroupCall({
    required CallModel senderCallData,
    required CallModel receiverCallData,
  }) async {
    await firestore
        .collection('call')
        .doc(senderCallData.callerId)
        .set(senderCallData.toMap());

    final groupSnapshot = await firestore
        .collection('groups')
        .doc(senderCallData.receiverId)
        .get();

    final group = GroupModel.fromMap(groupSnapshot.data()!);

    for (final id in group.membersUid) {
      await firestore
          .collection('call')
          .doc(id)
          .set(receiverCallData.toMap());
    }
  }

   Future<void> endCall({
    required String callerId,
    required String receiverId,
  }) async {
    await firestore.collection('call').doc(callerId).delete();
    await firestore.collection('call').doc(receiverId).delete();
  }

   Future<void> endGroupCall({
    required String callerId,
    required String receiverId,
  }) async {
    await firestore.collection('call').doc(callerId).delete();

    final groupSnapshot =
    await firestore.collection('groups').doc(receiverId).get();
    final group = GroupModel.fromMap(groupSnapshot.data()!);

    for (final id in group.membersUid) {
      await firestore.collection('call').doc(id).delete();
    }
  }
}