part of 'status_cubit.dart';

enum StatusListStatus { initial, loading, loaded, failure }
enum StatusUploadStatus { idle, loading, success, failure }

class StatusState {
  final StatusListStatus listStatus;
  final StatusUploadStatus uploadStatus;
  final StatusModel? myStatus;
  final List<StatusModel> contactsStatus;
  final String? errorMessage;
  final String? uploadErrorMessage;

  const StatusState({
    this.listStatus = StatusListStatus.initial,
    this.uploadStatus = StatusUploadStatus.idle,
    this.myStatus,
    this.contactsStatus = const [],
    this.errorMessage,
    this.uploadErrorMessage,
  });

  bool get hasMyStatus => myStatus != null;

  StatusState copyWith({
    StatusListStatus? listStatus,
    StatusUploadStatus? uploadStatus,
    StatusModel? myStatus,
    bool clearMyStatus = false,
    List<StatusModel>? contactsStatus,
    String? errorMessage,
    bool clearError = false,
    String? uploadErrorMessage,
    bool clearUploadError = false,
  }) {
    return StatusState(
      listStatus: listStatus ?? this.listStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      myStatus: clearMyStatus ? null : (myStatus ?? this.myStatus),
      contactsStatus: contactsStatus ?? this.contactsStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uploadErrorMessage: clearUploadError
          ? null
          : (uploadErrorMessage ?? this.uploadErrorMessage),
    );
  }
}