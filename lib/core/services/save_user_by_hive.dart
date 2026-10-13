import 'package:hive_ce_flutter/adapters.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/models/user_model_adapter.dart';

class UserRepository {
   UserRepository._();
  static final UserRepository instance = UserRepository._();
  factory UserRepository() {
    return instance;
  }

   static const String _boxName = 'user_box';
  static const String _userKey = 'current_user';

  late final Box<UserModel> _box;

   Future<void> init() async {
     await Hive.initFlutter();

     if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

     _box = await Hive.openBox<UserModel>(_boxName);
  }

   UserModel? getUser() => _box.get(_userKey);

   Future<void> saveUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

   Future<void> updateUser({
    String? userName,
    String? uId,
    String? image,
    String? phoneNumber,
    String? about,
    bool? isOnline,
    List<String>? groupId,
  }) async {
    final currentUser = getUser();
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      uid: uId ?? currentUser.uid,
      name: userName ?? currentUser.name,
      image: image ?? currentUser.image,
      phoneNumber: phoneNumber ?? currentUser.phoneNumber,
      about: about ?? currentUser.about,
      isOnline: isOnline ?? currentUser.isOnline,
      groupId: groupId ?? currentUser.groupId,
    );

    await saveUser(updatedUser);
  }


  Future<void> clearUser() async {
    await _box.delete(_userKey);
  }
}
