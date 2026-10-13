import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whats_app/core/network/firebase/database_service.dart';
import 'package:whats_app/core/network/firebase/database_service_impl.dart';
import 'package:whats_app/features/auth/data/datasource/phone_auth_datasource.dart';
import 'package:whats_app/features/auth/data/datasource/phone_auth_datasource_impl.dart';
import 'package:whats_app/features/auth/data/repos/phone_auth_repo-impl.dart';
import 'package:whats_app/features/auth/domain/repos/phone_auth_repo.dart';
import 'package:whats_app/features/auth/presentation/controllers/phone_auth_controller/phone_auth_bloc.dart';
import 'package:whats_app/features/auth/presentation/controllers/profile_controller/profile_cubit.dart';
import 'package:whats_app/features/call/controller/call_cubit.dart';
import '../../features/call/data/repo/call_repo.dart';
import '../../features/chat/controllers/chat_contacts_cubit/chat_contacts_cubit.dart';
import '../../features/chat/controllers/chat_message_cubit/chat_message_cubit.dart';
import '../../features/chat/controllers/send_message_cubit/send_message_cubit.dart';
import '../../features/chat/data/repos/chat_repo.dart';
import '../../features/group/data/repos/group_repository.dart';
import '../../features/group/group_cubit/group_cubit.dart';
import '../../features/status/data/repos/status_repo.dart';
import '../../features/status/status_cubit/status_cubit.dart';
import '../message_reply_cubit/message_reply_cubit.dart';
import '../network/firebase/firebase_service.dart';
import '../network/firebase/firebase_service_impl.dart';
import '../network/supabase/storage_service.dart';
import '../network/supabase/supabase_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl.registerLazySingleton<StorageService>(() => SupabaseStorageService(sl()));

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<FirebaseClient>(
    () => FirebaseClientImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<DatabaseService>(
    () => DatabaseServiceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<PhoneAuthDatasource>(
    () => PhoneAuthDatasourceImpl(sl(), databaseService: sl()),
  );

  sl.registerLazySingleton<PhoneAuthRepository>(
    () => PhoneAuthRepositoryImpl(sl(), databaseService: sl()),
  );

  sl.registerLazySingleton<ChatRepo>(
    () => ChatRepo(
      firestore: sl(),
      firebaseAuth: sl(),
      store: sl(),
      storageService: sl(),
    ),
  );

  sl.registerLazySingleton<CallRepository>(
    () => CallRepository(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<StatusRepo>(
    () => StatusRepo(
      firestore: sl(),
      firebaseAuth: sl(),
      store: sl(),
      storageService: sl(),
    ),
  );

  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepository(firestore: sl(), auth: sl(), storageService: sl()),
  );

  sl.registerFactory<PhoneAuthBloc>(() => PhoneAuthBloc(sl()));

  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl(), storage: sl()));

  sl.registerFactory<ChatMessagesCubit>(
    () => ChatMessagesCubit(chatRepo: sl(), groupRepository: sl()),
  );
  sl.registerFactory<ChatContactsCubit>(
    () => ChatContactsCubit(chatRepo: sl(), groupRepository: sl()),
  );
  sl.registerFactory<SendMessageCubit>(
    () => SendMessageCubit(chatRepo: sl(), groupRepository: sl()),
  );
  sl.registerFactory<MessageReplyCubit>(() => MessageReplyCubit());
  sl.registerFactory<StatusCubit>(() => StatusCubit(statusRepo: sl()));

  sl.registerFactory<GroupCubit>(() => GroupCubit(repository: sl()));
  sl.registerFactory<CallCubit>(() => CallCubit(repository: sl()));
}
