import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/models/phone_verification_phone.dart';
import '../entities/user_entity.dart';

abstract class PhoneAuthRepository {
  Future<Either<Failure, PhoneVerificationModel>> verifyPhoneNumber({
    required String phoneNumber,
  });

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<Either<Failure, PhoneVerificationModel>> resendOtp({
    required String phoneNumber,
      int? resendToken,
  });

  Stream<Either<Failure, UserEntity>> getStreamData({required String uId});

}