import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/save_user_by_hive.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/call_model.dart';
import '../data/repo/call_repo.dart';

part 'call_state.dart';

class CallCubit extends Cubit<CallState> {
  final CallRepository repository;

  CallCubit({required this.repository}) : super(CallInitial());


  Stream<DocumentSnapshot> get callStream => repository.callStream;


  Future<void> makeCall({
     required String receiverUid,
    required String receiverName,
    required String receiverProfilePic,
    required bool isGroupChat,
  }) async {
    emit(CallMakeLoading());
    try {
      final callId = const Uuid().v1();
      final UserModel? callerUser = await UserRepository().getUser();
      if(callerUser == null) return;
      final senderCallData = CallModel(
        callerId: callerUser.uid,
        callerName: callerUser.name,
        callerPic: callerUser.image ?? '',
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );

      final receiverCallData = CallModel(
        callerId: callerUser.uid,
        callerName: callerUser.name,
        callerPic: callerUser.image ?? '',
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false,
      );

      if (isGroupChat) {
        await repository.makeGroupCall(
          senderCallData: senderCallData,
          receiverCallData: receiverCallData,
        );
      } else {
        await repository.makeCall(
          senderCallData: senderCallData,
          receiverCallData: receiverCallData,
        );
      }
      emit(CallMakeSuccess(call: senderCallData, isGroupChat: isGroupChat));
    } catch (e) {
      emit(CallMakeFailure(e.toString()));
    }
  }

  Future<void> endCall({
    required String callerId,
    required String receiverId,
  }) async {
    emit(CallEndLoading());
    try {
      await repository.endCall(callerId: callerId, receiverId: receiverId);
      emit(CallEndSuccess());
    } catch (e) {
      emit(CallEndFailure(e.toString()));
    }
  }

  Future<void> endGroupCall({
    required String callerId,
    required String receiverId,
  }) async {
    emit(CallEndLoading());
    try {
      await repository.endGroupCall(
        callerId: callerId,
        receiverId: receiverId,
      );
      emit(CallEndSuccess());
    } catch (e) {
      emit(CallEndFailure(e.toString()));
    }
  }
}