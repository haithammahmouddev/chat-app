import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/network/firebase/database_service.dart';
import '../../../../../core/network/supabase/storage_service.dart';
import '../../../../../core/network/supabase/supabase_storage.dart';
import '../../../../../core/services/save_user_by_hive.dart';
import '../../../data/models/user_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.databaseService, {required this.storage}) : super(const ProfileState()) {
    loadUser();
  }

  final UserRepository _repository = UserRepository();
  final DatabaseService databaseService;
  final StorageService storage;

  Future<void> loadUser() async {
    final user = _repository.getUser();

    if (user == null) return;

    emit(
      state.copyWith(
        image: user.image,
        name: user.name,
        about: user.about,
        phone: user.phoneNumber,
      ),
    );
  }

   Future<void> pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);

      if (image == null) return;

      emit(
        state.copyWith(
          selectedImage: image,
          isLoading: true,
        ),
      );

      await _saveImage();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to pick image. Please try again.',
        ),
      );
    }
  }

  Future<void> _saveImage() async {
    if (state.selectedImage == null) return;

    try {
      final imageUrl = await storage.uploadFile(file: File(state.selectedImage!.path), path: 'users');
      await _repository.updateUser(image: imageUrl);

      final user = _repository.getUser();

      if (user != null) {
        await databaseService.updateData(
          path: 'users',
          docId: user.uid,
          data: {'image': imageUrl},
        );
      }

      emit(state.copyWith(image: imageUrl, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save image. Please try again.',
        ),
      );
    }
  }

  Future<void> updateName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName == state.name) return;

    try {
      await _repository.updateUser(userName: trimmedName);

      final user = _repository.getUser();

      if (user != null) {
        await databaseService.updateData(
          path: 'users',
          docId: user.uid,
          data: {'name': trimmedName},
        );
      }

      emit(state.copyWith(name: trimmedName));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update name.'));
    }
  }

  Future<void> updateAbout(String about) async {
    final trimmedAbout = about.trim();

    if (trimmedAbout.isEmpty || trimmedAbout == state.about) return;

    try {
      await _repository.updateUser(about: trimmedAbout);

      final user = _repository.getUser();

      if (user != null) {
        await databaseService.updateData(
          path: 'users',
          docId: user.uid,
          data: {'about': trimmedAbout},
        );
       }

      emit(state.copyWith(about: trimmedAbout,));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update about.'));
    }
  }

  Future<void> refresh() async {
    await loadUser();
  }
}