import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';

class DatabaseServiceImpl implements DatabaseService{
   final FirebaseFirestore firestore;
   DatabaseServiceImpl({required this.firestore});

  @override
  Future<void> setData({required String path, required String docId, required Map<String, dynamic> data}) async =>
      await firestore.collection(path).doc(docId).set(data);

  @override
  Future<void> updateData({required String path, required String docId, required Map<String, dynamic> data}) async =>
      await firestore.collection(path).doc(docId).update(data);

  @override
  Future<void> deleteData({required String path, required String docId}) async =>
      await firestore.collection(path).doc(docId).delete();

  @override
  Future<Map<String, dynamic>?> getData({required String path, required String docId}) async{
  final data =  await firestore.collection(path).doc(docId).get();
  return data.data();
  }

   @override
   Future<QuerySnapshot<Map<String, dynamic>>> getAllData({
     required String path,
   }) {
     return firestore.collection(path).get();
   }

   @override
   Stream<Map<String, dynamic>?> getUserDataStream({
     required String path,
     required String docId,
   }) async*{
    final result = firestore.collection(path)
        .doc(docId);

     await for (var result in result.snapshots()){
       yield result.data();
     }
   }

}