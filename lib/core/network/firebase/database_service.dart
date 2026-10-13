import '../../../features/auth/data/models/user_model.dart';
import '../../../features/auth/domain/entities/user_entity.dart';

abstract class DatabaseService {
  Future<void> setData({required String path, required String docId, required Map<String, dynamic> data});
  Future<void> updateData({required String path, required String docId, required Map<String, dynamic> data});
  Future<void> deleteData({required String path, required String docId});
  Future<Map<String, dynamic>?> getData({required String path, required String docId});
  Future<dynamic> getAllData({required String path});

  Stream<dynamic> getUserDataStream({required String path, required String docId});

  }