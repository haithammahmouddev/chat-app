class PhoneVerificationModel {
  final String verificationId;
  final int? resendToken;

  const PhoneVerificationModel({
    required this.verificationId,
    required this.resendToken,
  });
}