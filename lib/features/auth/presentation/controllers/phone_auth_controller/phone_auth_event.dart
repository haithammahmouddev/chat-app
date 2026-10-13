part of 'phone_auth_bloc.dart';

abstract class PhoneAuthEvent {
  const PhoneAuthEvent();
}

class VerifyPhoneNumberEvent extends PhoneAuthEvent {
  final String phoneNumber;

  const VerifyPhoneNumberEvent({
    required this.phoneNumber,
  });
}

class VerifyOtpEvent extends PhoneAuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyOtpEvent({
    required this.verificationId,
    required this.smsCode,
  });
}

class ResendOtpEvent extends PhoneAuthEvent {
  final String phoneNumber;
  final int? resendToken;

  const ResendOtpEvent({
    required this.phoneNumber,
    this.resendToken,
  });
}