import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:whats_app/core/services/save_user_by_hive.dart';
import '../data/models/status_model.dart';
import '../data/repos/status_repo.dart';

part 'status_state.dart';

class StatusCubit extends Cubit<StatusState> {
  final StatusRepo statusRepo;

  StatusCubit({required this.statusRepo}) : super(const StatusState());

  Future<void> loadStatuses() async {
    emit(state.copyWith(
      listStatus: StatusListStatus.loading,
      clearError: true,
    ));

    final myStatusFuture = statusRepo.getMyStatus();
    final contactsStatusFuture = statusRepo.getStatus();

    final myStatusResult = await myStatusFuture;
    final contactsStatusResult = await contactsStatusFuture;

    String? error;
    StatusModel? myStatus;
    List<StatusModel> contactsStatus = const [];

    myStatusResult.fold(
          (failure) => error = failure.message,
          (status) => myStatus = status,
    );

    contactsStatusResult.fold(
          (failure) => error ??= failure.message,
          (list) => contactsStatus = list,
    );

    if (error != null) {
      emit(state.copyWith(
        listStatus: StatusListStatus.failure,
        errorMessage: error,
      ));
      return;
    }

    emit(state.copyWith(
      listStatus: StatusListStatus.loaded,
      myStatus: myStatus,
      clearMyStatus: myStatus == null,
      contactsStatus: contactsStatus,
    ));
  }

  Future<void> addStatus({required File file}) async {
    emit(state.copyWith(
      uploadStatus: StatusUploadStatus.loading,
      clearUploadError: true,
    ));

    final user = UserRepository().getUser();
    if (user == null || user.image == null) {
      emit(state.copyWith(
        uploadStatus: StatusUploadStatus.failure,
        uploadErrorMessage: 'تعذر التعرف على بيانات المستخدم، حاول تسجل الدخول تاني',
      ));
      return;
    }

    final result = await statusRepo.uploadStatus(
      userName: user.name,
      profilePic: user.image!,
      phoneNumber: user.phoneNumber,
      statusImage: file,
    );

    result.fold(
          (failure) => emit(state.copyWith(
        uploadStatus: StatusUploadStatus.failure,
        uploadErrorMessage: failure.message,
      )),
          (_) {
        emit(state.copyWith(uploadStatus: StatusUploadStatus.success));
        loadStatuses();
      },
    );
  }

  void resetUploadStatus() {
    emit(state.copyWith(
      uploadStatus: StatusUploadStatus.idle,
      clearUploadError: true,
    ));
  }
}