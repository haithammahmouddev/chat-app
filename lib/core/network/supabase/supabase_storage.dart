import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whats_app/core/network/supabase/storage_service.dart';

class SupabaseStorageService implements StorageService {
  final SupabaseClient client;

  static const String _bucketName = 'users';

  SupabaseStorageService(this.client);

  @override
  Future<String> uploadFile({
    required File file,
    required String path,
  }) async {
    final extension = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final storagePath = '$path/$fileName';

    await client.storage.from(_bucketName).upload(
      storagePath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return client.storage.from(_bucketName).getPublicUrl(storagePath);
  }
}