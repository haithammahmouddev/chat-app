import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:whats_app/features/auth/domain/entities/user_entity.dart';
import 'package:whats_app/features/auth/domain/repos/phone_auth_repo.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final PhoneAuthRepository repository;

  PhoneAuthBloc(this.repository) : super(const PhoneAuthInitial()) {
    on<VerifyPhoneNumberEvent>(_onVerifyPhoneNumber);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
  }

  Future<void> _onVerifyPhoneNumber(
      VerifyPhoneNumberEvent event,
      Emitter<PhoneAuthState> emit,
      ) async {
    emit(const PhoneNumberVerifying());

    final result = await repository.verifyPhoneNumber(
      phoneNumber: event.phoneNumber,
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(
        PhoneNumberVerificationFailure(message: failure.message),
      ),
          (verification) => emit(
        PhoneCodeSent(
          verificationId: verification.verificationId,
          resendToken: verification.resendToken,
        ),
      ),
    );
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event,
      Emitter<PhoneAuthState> emit,
      ) async {
    emit(const OtpVerifying());

    final result = await repository.verifyOtp(
      verificationId: event.verificationId,
      smsCode: event.smsCode,
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(
        OtpVerificationFailure(message: failure.message),
      ),
          (user) => emit(
        PhoneAuthSuccess(user: user),
      ),
    );
  }

  Future<void> _onResendOtp(
      ResendOtpEvent event,
      Emitter<PhoneAuthState> emit,
      ) async {
    emit(const OtpResending());

    final result = await repository.resendOtp(
      phoneNumber: event.phoneNumber,
      resendToken: event.resendToken,
    );

    if (emit.isDone) return;

    result.fold(
          (failure) => emit(
        OtpResendFailure(message: failure.message),
      ),
          (verification) => emit(
        OtpResendSuccess(
          verificationId: verification.verificationId,
          resendToken: verification.resendToken,
        ),
      ),
    );
  }
  StreamSubscription? _streamSubscription;

  void fetchUserData({required String uId}){
    _streamSubscription = repository.getStreamData(uId: uId).listen((result){
      result.fold((failure){
        emit(UserDataFailure(message: failure.message,));
      }, (success){
        emit(UserDataLoaded(user: success));
      });
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}