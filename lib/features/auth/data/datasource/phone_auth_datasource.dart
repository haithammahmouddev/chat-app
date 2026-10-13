import '../models/phone_verification_phone.dart';
import '../models/user_model.dart';

abstract class PhoneAuthDatasource {
  Future<PhoneVerificationModel> verifyPhoneNumber({
    required String phoneNumber,
  });

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<PhoneVerificationModel> resendOtp({
    required String phoneNumber,
      int? resendToken,
  });

}