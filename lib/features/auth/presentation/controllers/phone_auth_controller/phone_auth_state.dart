part of 'phone_auth_bloc.dart';

abstract class PhoneAuthState {
  const PhoneAuthState();
}

class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneNumberVerifying extends PhoneAuthState {
  const PhoneNumberVerifying();
}

class PhoneCodeSent extends PhoneAuthState {
  final String verificationId;
  final int? resendToken;

  const PhoneCodeSent({
    required this.verificationId,
    required this.resendToken,
  });
}

class PhoneNumberVerificationFailure extends PhoneAuthState {
  final String message;

  const PhoneNumberVerificationFailure({required this.message});
}

class OtpVerifying extends PhoneAuthState {
  const OtpVerifying();
}

class PhoneAuthSuccess extends PhoneAuthState {
  final UserEntity user;

  const PhoneAuthSuccess({required this.user});
}

class OtpVerificationFailure extends PhoneAuthState {
  final String message;

  const OtpVerificationFailure({required this.message});
}

class OtpResending extends PhoneAuthState {
  const OtpResending();
}

class OtpResendSuccess extends PhoneAuthState {
  final String verificationId;
  final int? resendToken;

  const OtpResendSuccess({
    required this.verificationId,
    required this.resendToken,
  });
}

class OtpResendFailure extends PhoneAuthState {
  final String message;

  const OtpResendFailure({required this.message});
}

class UserDataLoaded extends PhoneAuthState {
  final UserEntity user;

  const UserDataLoaded({required this.user});
}
class UserDataFailure extends PhoneAuthState {
  final String message;

  const UserDataFailure({required this.message});
}