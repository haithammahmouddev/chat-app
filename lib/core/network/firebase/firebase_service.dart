import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseClient {
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    int? forceResendingToken,
  });

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

}